json.set! :bubbles_arichives do
  json.array! @bubbles_archives do |bubbles_archive|
    json.extract! bubbles_archive, :id, :header, :image, :body, :footer_type, :footer, :created_at, :updated_at, :header_size, :header_gravity, :header_align, :header_bold, :header_color, :header_background, :hero_size, :hero_align, :hero_ratio, :hero_background, :body_size, :body_gravity, :body_align, :body_bold, :body_color,:body_background, :footer_size, :footer_gravity, :footer_align, :footer_bold, :footer_color, :footer_background, :footer_button, :footer_uri, :footer_message, :footer_data
  end
end