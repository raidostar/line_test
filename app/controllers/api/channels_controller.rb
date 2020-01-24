class Api::ChannelsController < ApplicationController
  def index
  end

  def create
    @channel = Channel.new(channels_params)
    group = current_user.group
    @group = Group.find_by(group: group)
    channels_limit = @group.channels_limit
    @channels = []
    if @group.channels.present?
      @channels = @group.channels.split(",")
    end

    if channels_limit <= @channels.length
      puts 'rejected!'
    else
      if @channel.save
        channel = Channel.last
        @channels.push(channel.id)
        @group.update(channels: @channels.join(","))
        render :show, status: :ok
      else
        render json: @channel.errors, status: :unprocessable_entity
      end
    end
  end

  def show
  end

  def fetch_channels
    group = current_user.group
    @group = Group.find_by(group: group)
    if @group.channels.present?
      channel_ids = @group.channels.split(",")
      @channels = Channel.where(id: channel_ids)
      render :index, status: :ok
    else
      render json: nil, status: :ok
    end
  end

  def fetch_current_channel
    channel_id = current_user.target_channel
    @channel = Channel.find_by(channel_id: channel_id)
    render :show, status: :ok
  end

  def update
    @channel = Channel.find(params[:id])
    @channel.update(channels_params)
    render :show, status: :ok
  end

  def destroy
    id = params[:id]
    @channel = Channel.find(id)
    @channel.destroy
  end

  private

  def channels_params
    if params[:channel].present?
      params.require(:channel).permit(
        :id, :channel_name, :channel_id, :channel_secret, :channel_token, :channel_user_id, :status, :image
        )
    else
      params.permit(
        :id, :channel_name, :channel_id, :channel_secret, :channel_token, :channel_user_id, :status, :image
        )
    end
  end
end