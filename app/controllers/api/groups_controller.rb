class Api::GroupsController < ApplicationController
  def index
    @groups = Group.all
  end

  def show_with_group_key
    @group = Group.find_by(group: params[:group],group_key: params[:group_key])
    if @group.present?
      render :show, status: :ok
    else
      puts "no data"
    end
  end

  def create
    @group = Group.new(groups_params)
    if @group.save
      render :show, status: :created
    else
      render json: @groups.errors, status: :unprocessable_entity
    end
  end

  private

  def groups_params
    params.fetch(:groups, {}).permit(
      :id, :group, :group_id, :created_at, :updated_at
    )
  end
end