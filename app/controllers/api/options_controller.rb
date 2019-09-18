class Api::OptionsController < ApplicationController
  def index
    @options = Option.where(user_group: current_user.group)
  end

  def show
    @option = Option.find(params[:id])
  end

  def create
    @option = Option.new(option_params)
    if @option.save
      render :show, status: :ok
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @option = Option.find(params[:id])
    @option.destroy
    render :index, status: :ok
  end

  def update
    @option = Option.find(params[:id])

    if @option.update(option_params)
      render :show, status: :ok
    else
      render json: @reaction.errors, status: :unprocessable_entity
    end
  end

  private

  def option_params
    params[:option][:user_group] = current_user.group
    if params[:option][:action_count].present?
      params[:option][:action_count] = params[:option][:action_count].to_i
    end
    params.require(:option).permit(
      :name, :match_reaction, :action_count, :user_group, :tag, :target_day, :target_time, :target_keyword, :target_friend
      )
  end
end