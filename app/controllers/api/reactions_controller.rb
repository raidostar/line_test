class Api::ReactionsController < ApplicationController

  def index
    option = Option.find(params[:option_id])
    @reactions=[]
    if option.attributes["match_reaction"].present?
      action_ids = option.attributes["match_reaction"].split(",")
      action_ids.each do |id|
        reaction = Reaction.find(id)
        @reactions.push(reaction)
      end
    end
  end

  def index_all_except
    @option = Option.find(params[:option_id])
    temp = @option.attributes['match_reaction'].split(",")
    @reactions = Reaction.where.not(id: temp)

    render json: @reactions, status: :ok
  end

  def show
    @reaction = Reaction.find(params[:id])
  end

  def create
    @reaction = Reaction.new(reaction_params)

    option_id = params[:match_option]
    @option = Option.find(option_id)

    if @reaction.save
      reaction = Reaction.last
      if @option.attributes["match_reaction"].present?
        match_reaction = @option.attributes["match_reaction"] + reaction.attributes["id"].to_s + ","
      else
        match_reaction = reaction.attributes["id"].to_s + ","
      end
      if @option.update({match_reaction: match_reaction})
        render json: @reaction, status: :ok
      else
        render json: @option.errors, status: :unprocessable_entity
      end
    else
      render json: @reaction.errors, status: :unprocessable_entity
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
    puts "1번"
    if @option.attributes["match_reaction"].present?
      puts "2번"
      match_reaction = @option.attributes["match_reaction"] + params[:reaction_id].to_s + ","
    else
      puts "3번"
      match_reaction = params[:reaction_id].to_s + ","
    end
    puts "a번"
    if @option.update({match_reaction: match_reaction})
      if @reaction.attributes["match_option"].present?
        puts "4번"
        match_option = @reaction.attributes["match_option"] + "," + params[:option_id].to_s
      else
        puts "5번"
        match_option = @reaction.attributes["id"].to_s
      end
      if @reaction.update({match_option: match_option})
        puts "6번"
        render json: @reaction, status: :ok
      else
        puts "7번"
        render json: @reaction.errors, status: :unprocessable_entity
      end
    else
      puts "8번"
      render json: @option.errors, status: :unprocessable_entity
    end
  end

  def destroy
  end

  def cancel_reaction
    selected_reaction_id = params[:id] # integer
    selected_option_id = params[:match_option] # integer

    @reaction = Reaction.find(selected_reaction_id)
    option_ids = @reaction.attributes["match_option"].split(",") #string_array
    option_ids.delete(selected_option_id.to_s)
    match_option = ''
    if option_ids.present?
      option_ids.each do |id|
        match_option = match_option + id + ','
      end
    else
      match_option = nil
    end
    if @reaction.update(match_option: match_option)
      @option = Option.find_by(id: selected_option_id)
      if @option.present?
        reaction_ids = @option.attributes["match_reaction"].split(",") #string_array
        reaction_ids.delete(selected_reaction_id.to_s)
        match_reaction = ''
        if reaction_ids.present?
          reaction_ids.each do |id|
            match_reaction = match_reaction + id + ','
          end
        else
          match_reaction = nil
        end
        if @option.update(match_reaction: match_reaction)
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
        :id, :name, :contents, :reaction_type ,:user_group, :target_tag, :target_number,
        :image, :created_at, :updated_at, :match_option
        )
    else
      params[:user_group] = current_user.group
      params[:target_number] = 0
      params.permit(
        :id, :name, :contents, :reaction_type ,:user_group, :target_tag, :target_number, :created_at, :updated_at, :match_option, :image
        )
    end
  end
end