class Article < ApplicationRecord
  has_rich_text :description

  scope :desc, -> { reorder(created_at: :desc) }
end
