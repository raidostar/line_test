class Api::BubblesController < ApplicationController
  def index

  end
  def show

  end
  def create
    puts params[:bubble_list]
    bubble_ids = []
    bubble_list = params[:bubble_list]
    bubble_list.each do |bubble|
      @bubble = Bubble.new({header: bubble["header"],hero: bubble["hero"],body: bubble["body"],footer_type: 'text',footer: bubble["footer"]})
      if @bubble.save
        bubble_ids.push(@bubble.id)
      else
        render json: @bubble.errors, status: :unprocessable_entity
      end
    end
    render json: bubble_ids, status: :ok
  end

  private

  def bubble_params

  end
end