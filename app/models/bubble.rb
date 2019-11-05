class Bubble < ApplicationRecord
  mount_uploader :hero, ImageUploader

  before_destroy :destroy_assets

  def destroy_assets
    self.hero.remove! if self.hero
    self.save!
  end
end
