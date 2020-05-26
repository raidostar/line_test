class Channel < ApplicationRecord
  mount_uploader :image, ImageUploader
end
