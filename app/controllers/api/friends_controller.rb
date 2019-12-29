class Api::FriendsController < ApplicationController
  def index
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    @friends = Friend.where(channel_destination: channel_destination).order("last_message_time DESC")
  end

  def show
    @friend = Friend.find(params[:id])
  end

  def find_by_fr_account
    @friend = Friend.find_by(fr_account: params[:fr_account])
    render json: @friend, status: :ok
  end

  def update
    id = params[:id]
    @friend = Friend.find(id)
    tags = params[:tags].split(",")
    channel_id = current_user.target_channel
    tags.each do |tag|
      @tag = Tag.where(name: tag, channel_id: channel_id, tag_group: 'friend')
      if !@tag.present?
        @tag = Tag.new({name: tag, channel_id: channel_id, tag_group: 'friend'})
        if @tag.save
        else
          render json: @tag.errors, status: :unprocessable_entity
        end
      end
    end
    if @friend.tags.present?
      temp_array = @friend.tags.split(",") - tags
      temp_array.each do |tag|
        channel = Channel.find_by(channel_id: channel_id)
        channel_destination = channel.channel_destination
        friends = Friend.where(channel_destination: channel_destination)
        friends = friends.where("tags like ?","%#{tag}%").where.not(id: id)
        if !friends.present?
          @tag = Tag.find_by(name: tag, tag_group: 'friend')

          @tag.destroy
          options = Option.where("target_friend like ?","%#{tag}%").where(channe_id: channel.channe_id)
          options.each do |option|
            temp_array = option.target_friend.split(",")
            temp_array.delete(tag)
            option.update(target_friend: temp_array.join(","))
          end
        end
      end
    end

    if @friend.update(friends_params)
      render :show, status: :ok
    else
      render json: @friend.errors, status: :unprocessable_entity
    end
  end

  def number_of_add_by_date
    time = Time.new
    startDay = time.days_ago(6).beginning_of_day
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    @friends = Friend.where(created_at: startDay..time, channel_destination: channel_destination)
    if @friends.present?
      render :index, status: :ok
    else
      @friends = {}
      render json: @friends
    end
  end

  def number_of_block_by_date
    time = Time.new
    startDay = time.days_ago(6).beginning_of_day
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    @friends = Friend.where(block_at: startDay..time, channel_destination: channel_destination)

    if @friends.present?
      render :index, status: :ok
    else
      @friends = {}
      render json: @friends
    end
  end

  def fetch_targets
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    friends = Friend.where(channel_destination: channel_destination).where.not(tags: nil)
    data = []
    friends.each do |friend|
      data = data + friend.tags.split(",")
    end
    data = data.uniq
    render json: data, status: :ok
  end

  def get_date_info
    @timeArray = []
    for i in 0..6
      time = Time.new
      time = time.days_ago(i)
      str = time.strftime("%m-%d-%w")
      @timeArray.push(str)
    end
    render json: @timeArray, status: :ok
  end

  def get_weekly_friend_info
    @timeArray = []
    for i in 1..7
      info = {}

      time = DateTime.now
      time = time.beginning_of_day
      date = time.days_ago(i+1)
      time = time.days_ago(i)
      str = time.strftime("%m-%d-%w")
      info["date"]=str

      channel_id = current_user.target_channel
      @channel = Channel.find_by(channel_id: channel_id)
      channel_destination = @channel.channel_destination

      before_follow = Follow.find_by(channel_id: channel_id, date: date)
      after_follow = Follow.find_by(channel_id: channel_id, date: time)

      info["add"] = after_follow.follower - before_follow.follower
      info['block'] = after_follow.blocks - before_follow.blocks
      info["gap"] = after_follow.targetedReaches - before_follow.targetedReaches
      info['current'] = after_follow.targetedReaches

      @timeArray.push(info)
    end

    render json: @timeArray, status: :ok
  end

  private

  def friends_params
    params.require(:friend).permit(
      :id, :fr_account, :fr_name, :profile_pic, :profile_msg, :block, :created_at, :updated_at, :channel_destination, :last_message_time, :block_at, :follow_at, :tags
      )
  end

end
