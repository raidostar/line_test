class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def fetch_members
    status = current_user.status
    if status == 'admin'
      group = params[:group]
      @users = User.where(group: group).where.not(status: 'admin')
      render :index, status: :ok
    elsif status == 'master'
      group = current_user.group
      @users = User.where(group: group).where.not(status: 'admin')
      render :index, status: :ok
    else
      render json: nil, status: :ok
    end
  end

  def show
  end

  def show_current_user
    @user = current_user
    group = current_user.group
    @group = Group.find_by(group: group)
    if @group.admit
      render :show, status: :ok
    else
      render json: nil, status: :ok
    end
  end

  def id_check
    @user = User.find_by(email: params[:user_id])
    if @user.present?
      render json: 1, status: :ok
    else
      render json: 0, status: :ok
    end
  end

  def users_update
    ids = []
    users = params[:users]
    users.each do |user|
      id = user["id"]
      ids.push(id)
      status = user["status"]
      admit = user["admit"]

      @user = User.find_by(id: id)
      @user.update(status: status, admit: admit)
    end
    @users = User.where(id: ids)
    render :index, status: :ok
  end

  def admin_check
    password = params[:password]
    group_key = params[:group_key]

    group = current_user.group
    @group = Group.find_by(group: group)
    admin_bool = @group.authenticate(group_key)
    if admin_bool != false
      email = current_user.email
      user = User.find_for_authentication(email: email)
      admin = user.valid_password?(password)
      render json: admin, status: :ok
    else
      render json: false, status: :ok
    end
  end

  def save_target_channel
    target_channel = params[:target_channel]
    @user = current_user
    @user.update(target_channel: target_channel)
    render :show, status: :ok
  end
end
