class Api::GroupsController < ApplicationController
  def index
  end

  def show_with_group_key
    @group = Group.where(group_key: params[:group_key])
    render :show, status: :ok
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