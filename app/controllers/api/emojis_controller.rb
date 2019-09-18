class Api::EmojisController < ApplicationController
  def index
    @emojis = Emoji.all
    render :index, status: :ok
  end

  def create
    @emoji = Emoji.new(emoji_params)
    @emoji['unicode']
    if @emoji.save
      render :show, status: :created
    else
      render json: @emoji.errors, status: :unprocessable_entity
    end
  end

  def show
    @emoji = Emoji.find(params[:id])
    render :show, status: :ok
  end

  private

  def emoji_params
    params.fetch(:emoji, {}).permit(
      :moji_text,:img_url,:unicode
      )
  end
end