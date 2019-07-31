class Api::MessagesController < ApplicationController
  def index
    @messages = Message.all
  end

  def create
    @message = Message.new(message_params)
    @notify = Notify.new
    if @message.save
      render :show, status: :created
      @notify.send(@message)
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def show
    @message = Message.find(params[:id])
    render :show, status: :ok
  end

  def message_params
    params.fetch(:message, {}).permit(
      :id, :sender, :receiver, :contents, :image_url
      )
  end
end