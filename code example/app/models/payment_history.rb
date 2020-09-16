# frozen_string_literal: true

class PaymentHistory < ApplicationRecord
  belongs_to :user
  belongs_to :order, optional: true

  has_unique_field :identifier, length: 10, type: :human

  scope :confirmed, -> { where confirmed: true }
  scope :desc, -> { reorder created_at: :desc }

  after_update :update_balance, if: lambda {
    confirmed? && saved_change_to_confirmed?
  }

  after_create :update_balance, if: -> { amount.negative? }

  private

  def update_balance
    user.update balance: user.balance.to_f + amount.to_f
  end
end
