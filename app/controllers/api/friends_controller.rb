class Api::FriendsController < ApplicationController
  def index
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    @friends = Friend.where(channel_destination: channel_destination)
  end

  def show
    id = params[:id].to_i
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination
    @friends = Friend.where(channel_destination: channel_destination)
    @friend = @friends[id]
  end

  def find_by_fr_account
    @friend = Friend.find_by(fr_account: params[:fr_account])
    render json: @friend, status: :ok
  end

  def update
    id = params[:id]
    @friend = Friend.find(id)
    tags_before = @friend.tags.split(",")
    tags_after = params[:tags].split(",")
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    channel_destination = @channel.channel_destination

    # tag update, friend tags update, option target_friend update
    tags_for_delete = tags_before - tags_after
    tags_for_delete.each do |tag|
      friends_with_tag = Friend.where(channel_destination: channel_destination).where("tags like?","%#{tag}%").where.not(id: id)
      if !friends_with_tag.present?
        @options = Option.where("target_friend like?","#{tag}").where(channel_id: channel_id)
        @options.each do |option|
          if option.target_friend.present?
            target_friend = option.target_friend.split(",")
            target_friend.delete(tag)
            option.update(target_friend: target_friend.join(","))
          end
        end
        @tag = Tag.find_by(name: tag, tag_group: 'friend', channel_id: channel_id)
        @tag.destroy
      end
    end

    tags_for_create = tags_after - tags_before
    tags_for_create.each do |tag|
      @tag = Tag.find_by(name: tag, tag_group: 'friend', channel_id: channel_id)

      if !@tag.present?
        @tag = Tag.new({name: tag, tag_group: 'friend', channel_id: channel_id})
        if @tag.save
        else
          render json: @tag.errors, status: :unprocessable_entity
        end
      end
    end
    if @friend.update(tags: tags_after.join(","))
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
      time = Time.current
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

      time = DateTime.current
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
