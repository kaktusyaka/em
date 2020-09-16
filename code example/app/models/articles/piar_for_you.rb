# frozen_string_literal: true

module Articles
  class PiarForYou < Article #:nodoc:
    scope :last_6_months, -> { where('created_at >= ?', 6.months.ago) }
  end
end
