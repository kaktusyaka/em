# frozen_string_literal: true

class Service < ApplicationRecord
  belongs_to :service_category
  has_many :orders, dependent: :destroy

  acts_as_list scope: :service_category

  has_rich_text :description

  validates :code, presence: true
  validates :name, presence: true
  validates :price_for_thousand, presence: true,
                                 numericality: { greater_than: 0 }
  validates :price_for_thousand_original, presence: true,
                                          numericality: { greater_than: 0 }
  validates :min_quantity, presence: true, numericality: { only_integer: true }
  validates :max_quantity, presence: true, numericality: { only_integer: true }
  validates :url_type, inclusion: { in: ['p', 'tv', 'profile'] }

  scope :active, -> { where(active: true).reorder(position: :asc) }
  scope :asc, -> { reorder created_at: :asc }

  class << self
    def to_select
      list = {}
      active.map do |s|
        list[s.service_category_id] ||= []
        list[s.service_category_id] << {
          id: s.id,
          name: s.name,
          price: s.price_for_thousand.to_f,
          minmax: "#{s.min_quantity}/#{s.max_quantity}",
          min_quantity: s.min_quantity,
          max_quantity: s.max_quantity,
          allow_timer: s.allow_timer,
          allow_comments: s.allow_comments,
          resource_label: s.resource_label,
          description: s.description.to_s,
          link_url_label: s.link_url_label
        }
      end
      list
    end
  end
end
