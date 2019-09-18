class Api::NotifiesController < ApplicationController
  def index
    group = current_user.group
    group_id = Group.select("group_id").where(group: group)
    @notifies = Notify.where(group_id: group_id).order("created_at DESC")
    render :index, status: :ok
  end

  def show
    @notify = Notify.find(params[:id])
    render :show, status: :ok
  end
end
