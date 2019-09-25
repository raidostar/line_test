class Api::TagsController < ApplicationController
  def index
    @tags = Tag.where(tag_group: params[:tag_group], user_group: current_user.group)
  end

  def show
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      render :show, status: :ok
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  def edit

  end

  def destroy
    @tag = Tag.find(params[:id])
    if @tag.destroy
      render :index, status: :ok
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  private

  def tag_params
    params[:tag][:user_group] = current_user.group
    params.require(:tag).permit(
      :name, :tag_group, :user_group
      )
  end
end