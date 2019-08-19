class Api::FriendsController < ApplicationController
  def index
    group = current_user.group
    @group = Group.select("group_id").where(group: group)
    @friends = Friend.where(group_id: @group).order("last_message_time DESC")
  end

  def show
    @friend = Friend.find(params[:id])
  end

end