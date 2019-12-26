class Api::RichmenusController < ApplicationController
  def index
    channel_id = current_user.target_channel
    @richmenus = Richmenu.where(channel_id: channel_id)
  end

  def create
  end

  def show
  end
end