class Message < ApplicationRecord
  mount_uploader :image, ImageUploader
end
