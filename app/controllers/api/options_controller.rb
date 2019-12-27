class Api::OptionsController < ApplicationController
  def index
    if params[:option_type]=='welcomeReply'
      option = Option.find_by(channel_id: current_user.target_channel, option_type: params[:option_type])
      if !option.present?
        @option = Option.new(channel_id: current_user.target_channel, option_type: params[:option_type])
        @option.save
      end
    end
    @options = Option.where(channel_id: current_user.target_channel, option_type: params[:option_type])
  end

  def show
    @option = Option.find(params[:id])
  end

  def index_by_tag
    tag = Tag.find_by(id: params[:tag_id])
    @options = []
    options = Option.where(channel_id: current_user.target_channel, option_type: params[:option_type])
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

  def update_option_bool
    @option = Option.find_by(option_type: 'welcomeReply', channel_id: current_user.target_channel)
    if @option.present?
      @option.update(bool: params[:bool])
    end
    render :show, status: :ok
  end

  def update_option_remind
    @option = Option.find_by(option_type: 'welcomeReply', channel_id: current_user.target_channel)
    @option.update(remind_after: params[:remind_after])
    render :show, status: :ok
  end

  def create
    option_type = params[:option_type]
    channel_id = current_user.target_channel
    if option_type=="welcomeReply"
      @option = Option.find_by(channel_id: channel_id,option_type: option_type)
      if @option.present?
        render :show, status: :ok
      else
        save_option(option_params)
      end
    else
      save_option(option_params)
    end
  end

  def save_option(option)
    @option = Option.new(option)
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
      tagCheck = Tag.where(name: tag, tag_group: 'option', channel_id: current_user.target_channel)
      if !tagCheck.present?
        @tag = Tag.new(name: tag, tag_group: 'option', channel_id: current_user.target_channel)
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
        match_option = reaction.match_option.split(",")
        match_option.delete(id.to_s)
        if reaction.update(match_option: match_option.join(","))
        else
          render json: reaction.errors, status: :unprocessable_entity
        end
      end
    end
    @option.destroy
  end

  def update
    @option = Option.find(params[:id])
    tags = params[:option][:tag].split(",")
    if @option.update(option_params)
      tag_create(tags)
      render :show, status: :ok
    else
      render json: @reaction.errors, status: :unprocessable_entity
    end
  end

  def keyword_check
    channel_id = current_user.target_channel
    result_options = []
    keyword = params[:keyword]
    options = Option.where(channel_id: channel_id).where("target_keyword like '%"+params[:keyword]+"%'")
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
    params[:option][:channel_id] = current_user.target_channel
    if params[:option][:action_count].present?
      params[:option][:action_count] = params[:option][:action_count].to_i
    end
    params.require(:option).permit(
      :id, :name, :match_reaction, :action_count, :tag, :created_at, :updated_at, :channel_id, :target_day, :target_time, :target_keyword, :target_friend, :option_type, :remind_after, :hit_count, :bool, :remind_bool
      )
  end
end