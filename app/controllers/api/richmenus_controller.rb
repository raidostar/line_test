class Api::RichmenusController < ApplicationController
  def index
    user_group = current_user.group
    @richmenus = Richmenu.where(user_group: user_group)
  end

  def create
  end

  def show
  end
end