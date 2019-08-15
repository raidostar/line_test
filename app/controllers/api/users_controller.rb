class Api::UsersController < ApplicationController
  def show
  end

  def show_current_user
    @user = current_user
    render :show, status: :ok
  end
end
