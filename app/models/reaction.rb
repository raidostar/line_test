class Reaction < ApplicationRecord
  mount_uploader :image, ImageUploader

  before_destroy :destroy_assets

  def destroy_assets
    self.image.remove! if self.image
    self.save!
  end

end
