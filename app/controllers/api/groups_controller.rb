class Api::GroupsController < ApplicationController
  def index

  end

  def show

  end

  def create
    @group = Group.new({group: 'FullouT',group_id: 'U4996f6a0f7a044453858ff6ed933f5cc'})

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