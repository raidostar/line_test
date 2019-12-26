class Api::NotifiesController < ApplicationController
  def index
    channel_id = current_user.target_channel
    channel = Channel.find_by(channel_id: channel_id)
    channel_destination = channel.channel_destination
    @notifies = Notify.where(channel_destination: channel_destination).order("created_at DESC")
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
      @channel = Channel.find_by(channel_id: current_user.target_channel)
      params[:notify][:sender] = @channel.channel_name
      params[:notify][:hit_count] = 0
      params[:notify][:channel_destination] = @channel.attributes["channel_destination"]
      params.require(:notify).permit(
        :id, :sender, :receiver, :contents, :created_at, :updated_at, :notify_type, :channel_destination, :target_tag, :hit_count, :image
        )
    else
      @channel = Channel.find_by(channel_id: current_user.target_channel)
      params[:sender] = @channel.channel_name
      params[:hit_count] = 0
      params[:channel_destination] = @channel.attributes["channel_destination"]
      params.permit(
        :id, :sender, :receiver, :contents, :created_at, :updated_at, :notify_type, :channel_destination, :target_tag, :hit_count, :image
        )
    end
  end
end
