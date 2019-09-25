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

  def create
    @notify = Notify.new(notify_params)

    if @notify.save
      if @notify.notify_type == "text"
        redirect_to broadcast_text(contents)
      elsif @notify.notify_type == "stamp"
        redirect_to broadcast_stamp(contents)
      elsif @notify.notify_type == "image"
        redirect_to broadcast_image(@notify.image)
      elsif @notify.notify_type == "text+image"
        redirect_to broadcast_text(contents)
        redirect_to broadcast_image(@notify.image)
      elsif @notify.notify_type == "map"
        redirect_to broadcast_map(address_array)
      end
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  private

  def notify_params
    if params[:notify].present?
      params[:notify][:sender] = current_user.group
      params[:notify][:receiver] = 'ALL'
      params[:notify][:hit_count] = 0
      @group = Group.find_by(group: current_user.group)
      params[:notify][:group_id] = @group.attributes["group_id"]
      params.require(:notify).permit(
        :id, :sender, :receiver, :contents, :created_at, :updated_at, :notify_type, :group_id, :target_tag, :hit_count, :image
        )
    else
      params[:sender] = current_user.group
      params[:receiver] = 'ALL'
      params[:hit_count] = 0
      @group = Group.find_by(group: current_user.group)
      params[:group_id] = @group.attributes["group_id"]
      params.permit(
        :id, :sender, :receiver, :contents, :created_at, :updated_at, :notify_type, :group_id, :target_tag, :hit_count, :image
        )
    end
  end
end
