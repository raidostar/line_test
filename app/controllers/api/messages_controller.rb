class Api::MessagesController < ApplicationController
  require 'api/lines_controller'

  def index
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    notify = ['notified','reminded','welcome']
    @messages = Message.where(channel_destination: channel_destination).where.not(check_status: notify).order("id DESC")
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      render :show, status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def show
    @message = Message.find(params[:id])
    render :show, status: :ok
  end

  def index_with_id
    fr_account = params[:fr_account]
    friend = Friend.find_by(fr_account: fr_account)
    tags = nil
    if friend.tags.present?
      tags = friend.tags.split(",")
    end
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    @messages = Message.where(fr_account: params[:fr_account], channel_destination: channel_destination).or(Message.where(receiver: 'ALL', channel_destination: channel_destination)).or(Message.where(receiver: tags, channel_destination: channel_destination)).order("id")
    render :index, status: :ok
  end

  def timely_messages
    now = Time.current
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    channel_name = channel.channel_name
    channel_destination = channel.channel_destination
    timely = {}
    start_day = now.beginning_of_day
    end_day = now.end_of_day
    start_week = now.beginning_of_week
    end_week = now.end_of_week
    start_month = now.beginning_of_month
    end_month = now.end_of_month

    daily_messages = Message.where(check_status: 'answered', created_at: start_day..end_day, channel_destination: channel_destination).length
    weekly_messages = Message.where(check_status: 'answered', created_at: start_week..end_week, channel_destination: channel_destination).length
    monthly_messages = Message.where(check_status: 'answered', created_at: start_month..end_month, channel_destination: channel_destination).length

    timely[:daily] = daily_messages
    timely[:weekly] = weekly_messages
    timely[:monthly] = monthly_messages
    render json: timely, status: :ok
  end

  def get_last_message
    message = Message.where(fr_account: params[:fr_account]).last
    render json: message, status: :ok
  end

  def read_message
    message = Message.find(params[:id])
    if message.check_status == "unchecked"
      message.update(check_status: 'unreplied')
    end
    render json: message, status: :ok
  end

  def check_message
    message = Message.find(params[:id])
    if message.check_status == "unchecked"||message.check_status == "unreplied"
      message.update(check_status: 'checked')
    end
    render json: message, status: :ok
  end

  def fetch_reply
    reply_token = params[:reply_token]
    @messages = Message.where(reply_token: reply_token)
    render :index, status: :ok
  end

  def fetch_messages_data
    infos = []
    answer = ['answered','notified','reminded','welcome']
    datetime = DateTime.current
    start_time = datetime.beginning_of_day
    end_time = start_time + 1
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    channel_destination = channel.channel_destination
    if params[:reply_boolean] == false
      message_info = {
        name: "リプライ数",
        data: {}
      }
    else
      message_info = {
        name: "メッセージ配信数",
        data: {}
      }
    end
    case params[:timeOption]
    when "oneDay"
      for i in 0..23 do
        if params[:reply_boolean] == false
          messages = Message.where(channel_destination: channel_destination, created_at: ((start_time)..(end_time))).where.not(check_status: answer)
        else
          messages = Message.where(channel_destination: channel_destination, check_status: 'answered', created_at: ((start_time)..(end_time)))
        end
        hourly_messages = messages.where(created_at: (start_time+i.hour)..(start_time+(i+1).hour))
        time_record = (start_time+i.hour).hour.to_s
        if time_record.length < 2
          time_record = "0"+time_record
        end
        time_record = time_record + ":00"
        message_info[:data][time_record] = hourly_messages.length
      end
    when "oneWeek"
      start_day = start_time - 6
      for i in 0..6 do
        if params[:reply_boolean] == false
          messages = Message.where(channel_destination: channel_destination, created_at: ((start_day)..(end_time))).where.not(check_status: answer)
        else
          messages = Message.where(channel_destination: channel_destination, check_status: 'answered', created_at: ((start_day)..(end_time)))
        end
        daily_messages = messages.where(created_at: (start_day+i.day)..(start_day+(i+1).day))
        time_record = (start_day+i.day).strftime("%m/%d")
        message_info[:data][time_record] = daily_messages.length
      end
    when "oneMonth"
      start_day = start_time - 30
      for i in 0..30 do
        if params[:reply_boolean] == false
          messages = Message.where(channel_destination: channel_destination, created_at: ((start_day)..(end_time))).where.not(check_status: answer)
        else
          messages = Message.where(channel_destination: channel_destination, check_status: 'answered', created_at: ((start_day)..(end_time)))
        end
        daily_messages = messages.where(created_at: (start_day+i.day)..(start_day+(i+1).day))
        time_record = (start_day+i.day).strftime("%m/%d")
        message_info[:data][time_record] = daily_messages.length
      end
    when "oneYear"
      if params[:reply_boolean] == false
        messages = Message.where('extract(year from created_at) = ?',datetime.year).where(channel_destination: channel_destination).where.not(check_status: answer)
      else
        messages = Message.where('extract(year from created_at) = ?',datetime.year).where(channel_destination: channel_destination,check_status: 'answered')
      end
      for i in 0..11 do
        monthly_messages = messages.where('extract(month from created_at) = ?',i+1)
        time_record = (i+1).to_s + '月'
        message_info[:data][time_record] = monthly_messages.length
      end
    end

    infos.push(message_info)
    render json: infos, status: :ok
  end

  def fetch_messages_time_data
    data = messages_data(params[:reply_boolean],params[:timeOption])
    render json: data, status: :ok
  end

  def messages_data(reply_boolean,timeOption)
    infos = []
    answer = ['answered','notified','reminded','welcome']
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    channel_destination = channel.channel_destination

    if reply_boolean == false
      messages = Message.where(channel_destination: channel_destination).where.not(check_status: answer)
      message_info = {
        name: "リプライ数",
        data: {}
      }
    else
      messages = Message.where(channel_destination: channel_destination, check_status: 'answered')
      message_info = {
        name: "メッセージ数",
        data: {}
      }
    end
    message_array = messages.to_a
    times = []
    message_times = []

    case timeOption
    when "hourly"
      for i in 0..23 do
        if i < 10
          times.push("0"+i.to_s+":00")
        else
          times.push(i.to_s+":00")
        end
        message_times.push(0)
      end
      for i in 0...message_array.length do
        num = message_array[i].created_at.hour
        message_times[num] = message_times[num] + 1
      end
    when "wdaily"
      times = ['日','月','火','水','木','金','土']
      message_times = [0,0,0,0,0,0,0]
      for i in 0...message_array.length do
        num = message_array[i].created_at.wday
        message_times[num] = message_times[num] + 1
      end
    when "daily"
      for i in 0..30 do
        times.push((i+1).to_s+'日')
        message_times.push(0)
      end
      for i in 0...message_array.length do
        num = message_array[i].created_at.day - 1
        message_times[num] = message_times[num] + 1
      end
    when "monthly"
      for i in 0..11 do
        times.push((i+1).to_s+'月')
        message_times.push(0)
      end
      for i in 0...message_array.length do
        num = message_array[i].created_at.month - 1
        message_times[num] = message_times[num] + 1
      end
    end
    for i in 0...times.length do
      message_info[:data][times[i]] = message_times[i]
    end

    infos.push(message_info)
    return infos
  end

  def fetch_personal_message_data
    id = params[:id].to_i
    data = personal_message_data(params[:reply_boolean], id, params[:time_option])
    render json: data, status: :ok
  end

  def personal_message_data(reply_boolean,id,time_option)
    infos = []
    answer = ['answered','notified','reminded','welcome']
    fr_account = get_fr_account(id)
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    if reply_boolean == false
      messages = Message.where(channel_destination: channel_destination, fr_account: fr_account).where.not(check_status: answer)
      message_info = {
        name: "リプライ数",
        data: {}
      }
    else
      messages = Message.where(channel_destination: channel_destination, fr_account: fr_account, check_status: 'answered')
      message_info = {
        name: "メッセージ数",
        data: {}
      }
    end
    message_array = messages.to_a
    times = []
    message_times = []
    case time_option
    when "hourly"
      for i in 0..23 do
        if i < 10
          times.push("0"+i.to_s+":00")
        else
          times.push(i.to_s+":00")
        end
        message_times.push(0)
      end
      for i in 0...message_array.length do
        num = message_array[i].created_at.hour
        message_times[num] = message_times[num] + 1
      end
    when "wdaily"
      times = ['日','月','火','水','木','金','土']
      message_times = [0,0,0,0,0,0,0]
      for i in 0...message_array.length do
        num = message_array[i].created_at.wday
        message_times[num] = message_times[num] + 1
      end
    when "daily"
      for i in 0..30 do
        times.push((i+1).to_s+'日')
        message_times.push(0)
      end
      for i in 0...message_array.length do
        num = message_array[i].created_at.day - 1
        message_times[num] = message_times[num] + 1
      end
    when "monthly"
      for i in 0..11 do
        times.push((i+1).to_s+'月')
        message_times.push(0)
      end
      for i in 0...message_array.length do
        num = message_array[i].created_at.month - 1
        message_times[num] = message_times[num] + 1
      end
    end
    for i in 0...times.length do
      message_info[:data][times[i]] = message_times[i]
    end

    infos.push(message_info)
    return infos
  end

  def fetch_message_type_data
    infos = []
    answer = ['answered','notified','reminded','welcome']
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    channel_destination = channel.channel_destination
    message_align = {}
    if params[:reply_boolean] == false
      if params[:id].present?
        id = params[:id].to_i
        fr_account = get_fr_account(id)
        messages = Message.where(channel_destination: channel_destination, fr_account: fr_account).where.not(check_status: answer)
      else
        messages = Message.where(channel_destination: channel_destination).where.not(check_status: answer)
      end
    else
      if params[:id].present?
        id = params[:id].to_i
        fr_account = get_fr_account(id)
        messages = Message.where(channel_destination: channel_destination, fr_account: fr_account, check_status: 'answered')
      else
        messages = Message.where(channel_destination: channel_destination, check_status: 'answered')
      end
      carousel_message = messages.where(message_type: "carousel")
      message_align["カルーセル"] = carousel_message.length
    end
    text_message = messages.where(message_type: "text")
    stamp_message = messages.where(message_type: "stamp")
    image_message = messages.where(message_type: "image")
    map_message = messages.where(message_type: "map")
    message_align["テキスト"] = text_message.length
    message_align["スタンプ"] = stamp_message.length
    message_align["イメージ"] = image_message.length
    message_align["マップ"] = map_message.length
    infos = message_align.sort{|(k1,v1),(k2,v2)| v2 <=> v1}
    render json: infos, status: :ok
  end

  def fetch_message_check_data
    infos = []
    answer = ['answered','notified','reminded','welcome']
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    channel_destination = channel.channel_destination
    message_align = {}

    if params[:reply_boolean] == false
      if params[:id].present?
        id = params[:id].to_i
        fr_account = get_fr_account(id)
        messages = Message.where(channel_destination: channel_destination,fr_account: fr_account).where.not(check_status: answer)
      else
        messages = Message.where(channel_destination: channel_destination).where.not(check_status: answer)
      end

      unreplied = messages.where(check_status: "unreplied")
      unchecked = messages.where(check_status: "unchecked")
      checked = messages.where(check_status: "checked")
      replied = messages.where(check_status: "replied")
      auto_replied = messages.where(check_status: "autoReplied")

      message_align["unreplied"] = unreplied.length
      message_align["unchecked"] = unchecked.length
      message_align["checked"] = checked.length
      message_align["replied"] = replied.length
      message_align["auto_replied"] = auto_replied.length

      infos = message_align.sort{|(k1,v1),(k2,v2)| v2 <=> v1}
    else
      reply_tokens = []
      if params[:id].present?
        id = params[:id].to_i
        fr_account = get_fr_account(id)
        replied_messages = Message.where(channel_destination: channel_destination,check_status: 'replied',fr_account: fr_account)
      else
        replied_messages = Message.where(channel_destination: channel_destination,check_status: 'replied')
      end
      replied_messages.each do |message|
        reply_tokens.push(message.reply_token)
      end
      replied = Message.where(reply_token: reply_tokens,check_status: 'answered')

      reply_tokens = []
      if params[:id].present?
        id = params[:id].to_i
        fr_account = get_fr_account(id)
        auto_replied_messages = Message.where(channel_destination: channel_destination,check_status: 'autoReplied',fr_account: fr_account)
      else
        auto_replied_messages = Message.where(channel_destination: channel_destination,check_status: 'autoReplied')
      end
      auto_replied_messages.each do |message|
        reply_tokens.push(message.reply_token)
      end
      auto_replied = Message.where(reply_token: reply_tokens,check_status: 'autoReplied')
      if params[:id].present?
        tags = []
        id = params[:id].to_i
        friend = get_friend(id)
        if friend.tags.present?
          tags = friend.attributes['tags'].split(",")
        end
        tags.push('ALL')
        broadcast = Notify.where(receiver: tags)
      else
        broadcast = Notify.where(receiver: 'ALL')
      end

      message_align["replied"] = replied.length
      message_align["autoReplied"] = auto_replied.length
      message_align["broadcast"] = broadcast.length

      infos = message_align.sort{|(k1,v1),(k2,v2)| v2 <=> v1}
    end
    render json: infos, status: :ok
  end

  def get_message_number
    fr_account = params[:fr_account]
    @messages = Message.where(fr_account: fr_account, check_status: 'answered')
    render json: @messages.length, status: :ok
  end

  def get_reply_number
    answer = ['answered','notified','reminded','welcome']
    fr_account = params[:fr_account]
    @messages = Message.where(fr_account: fr_account).where.not(check_status: answer)
    render json: @messages.length, status: :ok
  end

  def get_fr_account(id)
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    @friends = Friend.where(channel_destination: channel_destination)
    friend = @friends[id]
    fr_account = friend.fr_account
    return fr_account
  end

  def get_friend(id)
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    @friends = Friend.where(channel_destination: channel_destination)
    friend = @friends[id]
    return friend
  end

  private

  def message_params
    if params[:message].present?
      @channel = Channel.find_by(channel_id: current_user.target_channel)
      params[:message][:channel_destination] = @channel.channel_destination
      params.require(:message).permit(
        :id, :sender, :receiver, :contents ,:message_type, :message_id, :sticker_id, :package_id, :fr_account, :channel_destination, :reply_token, :check_status)
    else
      @channel = Channel.find_by(channel_id: current_user.target_channel)
      params[:channel_destination] = @channel.channel_destination
      params.permit(
        :id, :sender, :receiver, :contents ,:message_type, :message_id, :sticker_id, :package_id, :fr_account, :channel_destination, :reply_token, :check_status
        )
    end
  end
end
