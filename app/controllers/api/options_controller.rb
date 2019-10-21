class Api::OptionsController < ApplicationController
  def index
    @options = Option.where(user_group: current_user.group, option_type: params[:option_type])
  end

  def show
    @option = Option.find(params[:id])
  end

  def index_by_tag
    tag = Tag.find_by(id: params[:tag_id])
    @options = []
    options = Option.where(user_group: current_user.group, option_type: params[:option_type])
    options.each do |option|
      if option.tag.present?
        temp = option.tag.split(",")
        if tag.present?
          if temp.include? tag.attributes['name']
            @options.push(option)
          end
        end
      end
    end
    render json: @options, status: :ok
  end

  def create
    @option = Option.new(option_params)
    tags = params[:option][:tag].split(",")
    if @option.save
      tag_create(tags)
      render :show, status: :ok
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  def tag_create(tags)
    tags.each do |tag|
      tagCheck = Tag.where(name: tag, tag_group: 'option', user_group: current_user.group)
      if !tagCheck.present?
        @tag = Tag.new(name: tag, tag_group: 'option', user_group: current_user.group)
        if @tag.save
        else
          render json: @reaction.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    id = params[:id]
    @option = Option.find(id)
    id = id+','
    @reactions = Reaction.where("match_option like '%"+id+"%'")
    if @reactions.present?
      @reactions.each do |reaction|
        match_option = reaction.match_option.gsub(id,'')
        if reaction.update(match_option: match_option)
        else
          render json: reaction.errors, status: :unprocessable_entity
        end
      end
    end
    @option.destroy
  end

  def update
    @option = Option.find(params[:id])

    if @option.update(option_params)
      render :show, status: :ok
    else
      render json: @reaction.errors, status: :unprocessable_entity
    end
  end

  def keyword_check
    user_group = current_user.group
    result_options = []
    keyword = params[:keyword]
    options = Option.where(user_group: user_group).where("target_keyword like '%"+params[:keyword]+"%'")
    options.each do |opt|
      temp = opt.target_keyword.split(",")
      temp.each do |key|
        if key == keyword
          result_options.push(opt)
        end
      end
    end
    render json: result_options, status: :ok
  end

  private

  def option_params
    params[:option][:user_group] = current_user.group
    if params[:option][:action_count].present?
      params[:option][:action_count] = params[:option][:action_count].to_i
    end
    params.require(:option).permit(
      :id, :name, :match_reaction, :action_count, :tag, :created_at, :updated_at, :user_group, :target_day, :target_time, :target_keyword, :target_friend, :option_type, :remind_after
      )
  end
end