class Api::ChannelsController < ApplicationController
  def index
  end

  def create
    group = current_user.group
    @group = Group.find_by(group: group)
    @channel = Channel.new(channels_params)
    channels_limit = @group.channels_limit
    @channels = []
    channel_unlinked = nil
    if @group.channels.present?
      @channels = @group.channels.split(",")
      channel_unlinked = Channel.where(channel_id: @channels, channel_destination: nil)
    end
    if channels_limit <= @channels.length
      puts 'rejected!'
    elsif channel_unlinked.present?
      render json: "unlinked", status: :ok
    else
      if @channel.save
        channel = Channel.last
        @channels.push(channel.id)
        @group.update(channels: @channels.join(","))
        tag_groups = ['friend','option','reaction']
        tag_groups.each do |tag_group|
          @tag = Tag.new({name: 'ALL', tag_group: tag_group, channel_id: channel.channel_id})
          @tag.save
        end
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