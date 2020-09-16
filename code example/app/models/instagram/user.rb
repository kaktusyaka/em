class Instagram::User < ApplicationRecord
  belongs_to :promotion, counter_cache: true
end
