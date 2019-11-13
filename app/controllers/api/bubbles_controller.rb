class Api::BubblesController < ApplicationController
  def index
  end
  def show
  end
  def create
    bubble_ids = []
    bubble_num = params[:bubble_num].to_i

    for i in 0...bubble_num do
      header = params[:headers][i]
      image = params[:images][i]
      body = params[:bodies][i]
      footer = params[:footers][i]

      header_gravity = params[:header_gravity][i]
      header_align = params[:header_align][i]
      header_size = params[:header_size][i]
      header_bold = params[:header_bold][i]
      header_color = params[:header_color][i]
      header_background = params[:header_background][i]

      hero_size = params[:hero_size][i]
      hero_align = params[:hero_align][i]
      hero_background = params[:hero_background][i]
      hero_ratio = params[:hero_ratio][i]

      body_gravity = params[:body_gravity][i]
      body_align = params[:body_align][i]
      body_size = params[:body_size][i]
      body_bold = params[:body_bold][i]
      body_color = params[:body_color][i]
      body_background = params[:body_background][i]

      footer_gravity = params[:footer_gravity][i]
      footer_align = params[:footer_align][i]
      footer_size = params[:footer_size][i]
      footer_bold = params[:footer_bold][i]
      footer_color = params[:footer_color][i]
      footer_background = params[:footer_background][i]
      footer_type = params[:footer_type][i]
      footer_button = params[:footer_button][i]
      footer_uri = params[:footer_uri][i]
      footer_message = params[:footer_message][i]

      @bubble = Bubble.new({
        header: header, image: image, body: body, footer: footer, header_gravity: header_gravity, header_align: header_align,
        header_size: header_size,header_bold: header_bold,header_color: header_color,header_background: header_background,
        hero_size: hero_size, hero_align: hero_align, hero_background: hero_background, hero_ratio: hero_ratio,
        body_gravity: body_gravity, body_align: body_align, body_size: body_size, body_bold: body_bold, body_color: body_color,
        body_background: body_background, footer_gravity: footer_gravity, footer_align: footer_align, footer_size: footer_size,
        footer_bold: footer_bold, footer_color: footer_color, footer_background: footer_background, footer_type: footer_type,
        footer_button: footer_button, footer_uri: footer_uri, footer_message: footer_message
      })

      if @bubble.save
        bubble_ids.push(@bubble.id)
      else
        render json: @bubble.errors, status: :unprocessable_entity
      end
    end
    render json: bubble_ids, status: :ok
  end

  def fetch_bubbles
    ids = params[:ids]
    bubble_ids = ids.split(",")
    bubbles = []
    bubble_ids.each do |id|
      @bubble = Bubble.find(id)
      bubbles.push(@bubble)
    end
    render json: bubbles, status: :ok
  end

  private

  def bubble_params
    params.permit(bubbles: [
      bubble: [:header,:image,:body,:footer]
    ])
  end
end