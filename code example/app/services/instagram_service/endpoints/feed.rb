# frozen_string_literal: true

module InstagramService
  module Endpoints
    module Feed
      extend ActiveSupport::Concern

      included do
        def user_story_feed(user_id)
          # Get a user's story feed and current/replay broadcasts (if available)
          # :param user_id:
          # :return:
          check_csrftoken(account.account_session)
          authenticated_params

          endpoint = "feed/user/#{user_id}/story/"
          call_api(endpoint, 'GET', authenticated_params, unsigned: true)
        end
      end
    end
  end
end
