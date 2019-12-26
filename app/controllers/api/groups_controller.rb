class Api::GroupsController < ApplicationController
  skip_before_action :verify_authenticity_token, :except => [:update, :create]

  def index
  end

  def fetch_groups
    @groups = []
    if current_user.status == 'admin'
      groups = Group.all
      groups.each do |group|
        group = group.attributes
        if group["password_digest"].present?
          group["group_key"] = true
        else
          group["group_key"] = false
        end
        group["password_digest"] = ""
        @groups.push(group)
      end
      render json: @groups, status: :ok
    end
  end

  def find_group_key
    group = params[:group]
    group_key = params[:group_key]
    group = Group.find_by(group: group)
    result = group.authenticate(group_key)

    render json: result, status: :ok
  end

  def create
    group_name = params[:group]
    group = Group.find_by(group: group_name)
    if group.present?
      puts "rejected"
    else
      @group = Group.new
      @group.group = params[:group]
      @group.password = params[:group_key]
      @group.admit = params[:admit]
      @group.status = params[:status]
      @group.channels_limit = params[:channels_limit]
      @group.member_limit = params[:member_limit]
      if @group.save
        render :show, status: :ok
      else
        render json: groups.errors, status: :unprocessable_entity
      end
    end
  end

  def update
    @group = Group.find(params[:id])
    group = params[:group]
    password = params[:group_key]
    admit = params[:admit]
    status = params[:status]
    channels_limit = params[:channels_limit]
    member_limit = params[:member_limit]
    if params[:group_key].present?
      @group.update(group: group, password: password, admit: admit, status: status, channels_limit: channels_limit, member_limit: member_limit)
    else
      @group.update(group: group, admit: admit, status: status, channels_limit: channels_limit, member_limit: member_limit)
    end
    render :show, status: :ok
  end

  def make_group_key
    group_key = ((0..9).to_a + ("a".."z").to_a + ("A".."Z").to_a + ("!".."&").to_a).sample(12).join
    render json: group_key, status: :ok
  end

  def check_channel_limit
    group = current_user.group
    @group = Group.find_by(group: group)
    channels_limit = @group.channels_limit
    render json: channels_limit, status: :ok
  end

  private

  def groups_params
    params.fetch(:groups, {}).permit(
      :id, :group, :created_at, :updated_at, :admit, :status, :channels, :channels_limit, :member_limit
      )
  end
end