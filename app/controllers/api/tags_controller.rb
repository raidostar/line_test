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
    tag_name = @tag.attributes['name']+','
    case @tag.tag_group
    when 'option'
      options = Option.where("tag like '%"+tag_name+"%'")
      options.each do |opt|
        puts "1번"
        tag = opt.tag.gsub(tag_name,'')
        puts "2번"
        opt.update(tag: tag)
        puts "3번"
      end
    when 'reaction'
      reactions = Reaction.where("tag like '%"+tag_name+"%'")
      reactions.each do |act|
        tag = act.tag.gsub(tag_name,'')
        act.update(tag: tag)
      end
    end
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