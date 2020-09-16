class ServiceCategory < ApplicationRecord
  acts_as_list

  has_many :services, -> { reorder(position: :asc) }, dependent: :destroy

  default_scope -> { reorder(position: :asc) }
  scope :with_active_services, -> { joins(:services).where(services: { active: true }).distinct }

  validates :name, presence: true

  def self.categories
    with_active_services.uniq.map do |category|
      { name: category.name, id: category.id }
    end
  end
end
