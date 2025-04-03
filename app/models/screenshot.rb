class Screenshot < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  def self.ransackable_associations(auth_object = nil)
    ["image_attachment", "image_blob", "user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "updated_at", "user_id"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["blob_id", "created_at", "id", "id_value", "name", "record_id", "record_type"]
  end
end
