class Api::ReactionsController < ApplicationController
  def index
    option = Option.find(params[:option_id])
    @reactions = []
    if option.match_reaction.present?
      reaction_ids = option.match_reaction.split(",")
      @reactions = Reaction.where(id: reaction_ids).order(option.match_reaction)
    end
  end

  def index_welcome_reaction
    group = current_user.group
    option = Option.find_by(user_group: group, option_type: 'welcomeReply')
    @reactions = []
    if option.match_reaction.present?
      reaction_ids = option.match_reaction.split(",")
      @reactions = Reaction.where(id: reaction_ids)
    end
    render json: @reactions, status: :ok
  end

  def index_by_tag
    tag = Tag.find_by(id: params[:tag_id])
    @reactions = []
    reactions = Reaction.where(user_group: current_user.group)
    reactions.each do |reaction|
      if reaction.tag.present?
        temp = reaction.tag.split(",")
        if tag.present?
          if temp.include? tag.attributes['name']
            @reactions.push(reaction)
          end
        end
      end
    end
    render json: @reactions, status: :ok
  end

  def index_all_except
    @option = Option.find(params[:option_id])
    temp = @option.match_reaction.split(",")
    @reactions = Reaction.where(user_group: current_user.group).where.not(id: temp)

    render json: @reactions, status: :ok
  end

  def show
    @reaction = Reaction.find(params[:id])
  end

  def create
    @reaction = Reaction.new(reaction_params)
    option_id = params[:match_option]
    tags = params[:tag].split(",")
    @option = Option.find_by(id: option_id)
    if @reaction.save
      option_update(@option)
      tag_create(tags)
      render json: @reaction, status: :ok
    else
      render json: @reaction.errors, status: :unprocessable_entity
    end
  end

  def tag_create(tags)
    tags.each do |tag|
      tagCheck = Tag.where(name: tag, tag_group: 'reaction', user_group: current_user.group)
      if !tagCheck.present?
        @tag = Tag.new(name: tag, tag_group: 'reaction', user_group: current_user.group)
        if @tag.save
        else
          render json: @reaction.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def option_update(option)
    reaction = Reaction.last
    match_reaction = []
    if option.present?
      if option.match_reaction.present?
        match_reaction = option.match_reaction + "," + reaction.id.to_s
      else
        match_reaction = reaction.id.to_s
      end
      if option.update({match_reaction: match_reaction})
      else
        render json: @option.errors, status: :unprocessable_entity
      end
    end
  end

  def update
    @reaction = Reaction.find(params[:id])
    if @reaction.update(reaction_params)
      render :show, status: :ok
    else
      render json: @reaction.errors, status: :unprocessable_entity
    end
  end

  def link_option_reaction
    @reaction = Reaction.find(params[:reaction_id])
    @option = Option.find(params[:option_id])

    if @option.match_reaction.present?
      match_reaction = @option.match_reaction + "," + params[:reaction_id].to_s
    else
      match_reaction = params[:reaction_id].to_s
    end
    if @option.update({match_reaction: match_reaction})
      if @reaction.match_option.present?
        match_option = @reaction.match_option + "," + params[:option_id].to_s
      else
        match_option = params[:option_id].to_s
      end
      if @reaction.update({match_option: match_option})
        render json: @reaction, status: :ok
      else
        render json: @reaction.errors, status: :unprocessable_entity
      end
    else
      render json: @option.errors, status: :unprocessable_entity
    end
  end

  def destroy
    id = params[:id]
    @reaction = Reaction.find(id)
    id = id+','
    @options = Option.where("match_reaction like '%"+id+"%'")
    if @options.present?
      @options.each do |option|
        match_reaction = option.match_reaction.split(",")
        match_reaction.delete(id.to_s)
        if option.update(match_reaction: match_reaction.join(","))
        else
          render json: option.errors, status: :unprocessable_entity
        end
      end
    end
    @reaction.destroy
  end

  def cancel_reaction
    reaction_id = params[:id] # integer
    option_id = params[:match_option] # integer

    @reaction = Reaction.find(reaction_id)
    match_option = @reaction.match_option.split(",")
    match_option.delete(option_id.to_s)

    if @reaction.update(match_option: match_option.join(","))
      @option = Option.find_by(id: option_id)
      if @option.present?
        match_reaction = @option.match_reaction.split(",")
        match_reaction.delete(reaction_id.to_s)
        if @option.update(match_reaction: match_reaction.join(","))
          render :index, status: :ok
        else
          render json: @option.errors, status: :unprocessable_entity
        end
      end
    else
      render json: @reaction.errors, status: :unprocessable_entity
    end
  end

  private

  def reaction_params
    if params[:reaction].present?
      params[:reaction][:user_group] = current_user.group
      params[:reaction][:target_number] = 0
      params.require(:reaction).permit(
        :id, :name, :contents, :reaction_type ,:user_group, :tag, :target_number,
        :image, :created_at, :updated_at, :match_option
        )
    else
      params[:user_group] = current_user.group
      params[:target_number] = 0
      params.permit(
        :id, :name, :contents, :reaction_type ,:user_group, :tag, :target_number, :created_at, :updated_at, :match_option, :image
        )
    end
  end
end
