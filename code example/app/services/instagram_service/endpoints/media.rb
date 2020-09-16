# frozen_string_literal: true

module InstagramService
  module Endpoints
    module Media
      extend ActiveSupport::Concern

      included do
        def post_like(media_id, module_name = 'feed_timeline')
          # """
          # Like a post
          # :param media_id: Media id
          # :param module_name: Example: 'feed_timeline', 'video_view', 'photo_view'
          # :return:
          # .. code-block:: javascript
          # {"status": "ok"}
          endpoint = "media/#{media_id}/like/"
          params = {
            'media_id': media_id,
            'module_name': module_name,
            'radio_type': radio_type,
          }
          check_csrftoken(account.account_session)

          params.merge!(authenticated_params)

          call_api(endpoint, 'POST', params, {'d': '1'})
        end
      end
    end
  end
end
