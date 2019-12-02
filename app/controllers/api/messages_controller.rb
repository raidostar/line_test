class Api::MessagesController < ApplicationController
  require 'api/showmes_controller'

  def index
    group = current_user.group
    @group = Group.select("group_id").where(group: group)
    @messages = Message.where(group_id: @group).order("id DESC")
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
    group = current_user.group
    @group = Group.select("group_id").where(group: group)
    @messages = Message.where(fr_account: params[:fr_account], group_id: @group).order("id")
    render :index, status: :ok
  end

  def get_number_of_monthly_message
    now = Time.new
    startTime = now.beginning_of_month
    endTime = now.end_of_month
    group = current_user.group
    @messages = Message.where(created_at: startTime..endTime, receiver: group)

    render :index, status: :ok
  end

  def get_number_of_weekly_message
    now = Time.new
    startTime = now.beginning_of_week
    endTime = now.end_of_week
    group = current_user.group
    @messages = Message.where(created_at: startTime..endTime, receiver: group)

    render :index,  status: :ok
  end

  def get_number_of_daily_message
    now = Time.new
    startTime = now.beginning_of_day
    endTime = now.end_of_day
    group = current_user.group
    @messages = Message.where(created_at: startTime..endTime, receiver: group)
    render :index,  status: :ok
  end

  def get_number_of_seven_days
    now = Time.new
    startTime = now.days_ago(6).beginning_of_day
    group = current_user.group
    @messages = Message.where(created_at: startTime..now, receiver: group)

    render :index,  status: :ok
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
    datetime = DateTime.now
    start_time = datetime.beginning_of_day
    end_time = start_time + 1
    group = current_user.group
    group = Group.find_by(group: group)
    if params[:reply_boolean] == false
      message_info = {
        name: "メッセージ数",
        data: {}
      }
    else
      message_info = {
        name: "返事数",
        data: {}
      }
    end
    case params[:timeOption]
    when "oneDay"
      for i in 0..23 do
        if params[:reply_boolean] == false
          messages = Message.where(group_id: group.group_id, created_at: ((start_time)..(end_time))).where.not(check_status: 'answered')
        else
          messages = Message.where(group_id: group.group_id, check_status: 'answered', created_at: ((start_time)..(end_time)))
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
          messages = Message.where(group_id: group.group_id, created_at: ((start_day)..(end_time))).where.not(check_status: 'answered')
        else
          messages = Message.where(group_id: group.group_id, check_status: 'answered', created_at: ((start_day)..(end_time)))
        end
        daily_messages = messages.where(created_at: (start_day+i.day)..(start_day+(i+1).day))
        time_record = (start_day+i.day).strftime("%m/%d")
        message_info[:data][time_record] = daily_messages.length
      end
    when "oneMonth"
      start_day = start_time - 30
      for i in 0..30 do
        if params[:reply_boolean] == false
          messages = Message.where(group_id: group.group_id, created_at: ((start_day)..(end_time))).where.not(check_status: 'answered')
        else
          messages = Message.where(group_id: group.group_id, check_status: 'answered', created_at: ((start_day)..(end_time)))
        end
        daily_messages = messages.where(created_at: (start_day+i.day)..(start_day+(i+1).day))
        time_record = (start_day+i.day).strftime("%m/%d")
        message_info[:data][time_record] = daily_messages.length
      end
    when "oneYear"
      if params[:reply_boolean] == false
        messages = Message.where('extract(year from created_at) = ?',datetime.year).where(group_id: group.group_id).where.not(check_status: 'answered')
      else
        messages = Message.where('extract(year from created_at) = ?',datetime.year).where(group_id: group.group_id,check_status: 'answered')
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
    group = current_user.group
    group = Group.find_by(group: group)

    if reply_boolean == false
      messages = Message.where(group_id: group.group_id).where.not(check_status: 'answered')
      message_info = {
        name: "メッセージ値",
        data: {}
      }
    else
      messages = Message.where(group_id: group.group_id, check_status: 'answered')
      message_info = {
        name: "返事値",
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

  def fetch_message_type_data
    infos = []
    group = current_user.group
    group = Group.find_by(group: group)
    if params[:reply_boolean] == false
      messages = Message.where(group_id: group.group_id).where.not(check_status: 'answered')
    else
      messages = Message.where(group_id: group.group_id,check_status: 'answered')
    end
    message_align = {}

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
    group = current_user.group
    group = Group.find_by(group: group)
    if params[:reply_boolean] == false
      messages = Message.where(group_id: group.group_id).where.not(check_status: 'answered')
    else
      messages = Message.where(group_id: group.group_id, check_status: 'answered')
    end
    message_align = {}

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
    render json: infos, status: :ok
  end

  private

  def message_params
    if params[:message].present?
      @group = Group.find_by(group: current_user.group)
      params[:message][:group_id] = @group.group_id
      params.require(:message).permit(
        :id, :sender, :receiver, :contents ,:message_type, :message_id, :sticker_id, :package_id, :fr_account, :group_id, :reply_token, :check_status)
    else
      @group = Group.find_by(group: current_user.group)
      params[:group_id] = @group.group_id
      params.permit(
        :id, :sender, :receiver, :contents ,:message_type, :message_id, :sticker_id, :package_id, :fr_account, :group_id, :reply_token, :check_status
        )
    end
  end
end
