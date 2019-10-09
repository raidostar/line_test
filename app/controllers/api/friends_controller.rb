class Api::FriendsController < ApplicationController
  def index
    group = current_user.group
    @group = Group.select("group_id").where(group: group)
    @friends = Friend.where(group_id: @group).order("last_message_time DESC")
  end

  def show
    @friend = Friend.find(params[:id])
  end

  def find_by_fr_account
    @friend = Friend.find_by(fr_account: params[:fr_account])
    render json: @friend, status: :ok
  end

  def update
    @friend = Friend.find(params[:id])
    tags = params[:tags].split(",")
    tags.each do |tag|
      group = current_user.group
      @tag = Tag.where(name: tag, user_group: group, tag_group: 'friend')
      if !@tag.present?
        @tag = Tag.new({name: tag, user_group: group, tag_group: 'friend'})
        if @tag.save
        else
          render json: @tag.errors, status: :unprocessable_entity
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
    group = current_user.group
    group_id = Group.select("group_id").where(group: group)
    @friends = Friend.where(created_at: startDay..time, group_id: group_id)
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
    group = current_user.group
    group_id = Group.select("group_id").where(group: group)
    @friends = Friend.where(block_at: startDay..time, group_id: group_id)

    if @friends.present?
      render :index, status: :ok
    else
      @friends = {}
      render json: @friends
    end
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
      info = Hash.new

      time = Time.new
      time = time.days_ago(i)
      str = time.strftime("%m-%d-%w")
      info["date"]=str

      startTime = time.beginning_of_day
      endTime = time.end_of_day
      group = "FullouT"
      group_id = Group.select("group_id").where(group: group)

      @new_friends = Friend.where(follow_at: startTime..endTime, group_id: group_id)
      if @new_friends.present?
        info["add"]=@new_friends.length
      else
        info["add"]=0
      end

      @block_friends = Friend.where(block_at: startTime..endTime, group_id: group_id)
      if @block_friends.present?
        info["block"]=@block_friends.length
      else
        info["block"]=0
      end

      gap = info["add"]-info["block"]
      info["gap"] = gap

      @timeArray.push(info)
    end

    render json: @timeArray, status: :ok
  end

  private

  def friends_params
    params.require(:friend).permit(
      :id, :fr_account, :fr_name, :profile_pic, :profile_msg, :block, :created_at, :updated_at, :group_id, :last_message_time, :block_at, :follow_at, :tags
    )
  end

end
