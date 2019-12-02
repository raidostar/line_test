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

  def update
    @tag = Tag.find(params[:id])
    new_name = params[:name]
    if @tag.update(name: new_name)
      render :show, status: :ok
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    tag_name = @tag.attributes['name']
    if tag_name != "ALL"
      case @tag.tag_group
      when 'option'
        options = Option.where("tag like '%"+tag_name+"%'")
        options.each do |opt|
          option_tag = opt.tag.split(",")
          option_tag = option_tag.delete(tag_name)
          tag = option_tag.join(",")
          opt.update(tag: tag)
        end
      when 'reaction'
        reactions = Reaction.where("tag like '%"+tag_name+"%'")
        reactions.each do |act|
          reaction_tag = act.tag.split(",")
          reaction_tag = reaction_tag.delete(tag_name)
          tag = reaction_tag.join(",")
          act.update(tag: tag)
        end
      when 'friend'
        friends = Friend.where("tags like '%"+tag_name+"%'")
        friends.each do |friend|
          friend_tag = friend.tags.split(",")
          friend_tag = friend_tag.delete(tag_name)
          tag = friend_tag.join(",")
          friend.update(tag: tag)
        end
      end
      if @tag.destroy
        render :index, status: :ok
      else
        render json: @tag.errors, status: :unprocessable_entity
      end
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