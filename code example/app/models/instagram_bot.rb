class InstagramBot < ApplicationRecord

  attr_encrypted :session_id,
                 key: Rails.application.credentials
                           .dig(:instagram_bots, :session_id)

  attr_encrypted :password,
                 key: Rails.application.credentials
                           .dig(:instagram_bots, :password)

end
