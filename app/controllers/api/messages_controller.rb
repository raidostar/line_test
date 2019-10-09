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
    @messages = Message.where(fr_account: params[:fr_account], group_id: @group).order("created_at DESC")
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
