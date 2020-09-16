# frozen_string_literal: true

module InstagramService
  module Endpoints
    module Friendships
      extend ActiveSupport::Concern

      included do
        def friendships_create(user_id)
          # Follow a user
          # :param user_id: User id
          # :return:
          # {
              # "status": "ok",
              # "friendship_status": {
                  # "incoming_request": false,
                  # "followed_by": false,
                  # "outgoing_request": false,
                  # "following": true,
                  # "blocking": false,
                  # "is_private": false
              # }
          # }

          endpoint = "friendships/create/#{user_id}/"
          params = { 'user_id': user_id, 'radio_type': radio_type }
          check_csrftoken(account.account_session)
          params.merge!(authenticated_params)

          call_api(endpoint, 'POST', params)
        end

        def friendships_show(user_id)
          # Get friendship status with user id
          # :param user_id:
          # :return:
          # {
              # "status": "ok",
              # "incoming_request": false,
              # "is_blocking_reel": false,
              # "followed_by": false,
              # "is_muting_reel": false,
              # "outgoing_request": false,
              # "following": false,
              # "blocking": false,
              # "is_private": false
          # }
          check_csrftoken(account.account_session)

          endpoint = "friendships/show/#{user_id}/"
          call_api(endpoint, 'GET', authenticated_params, unsigned: true)
        end

        def user_followers(user_id, rank_token, kwargs = {})
          # Get user followers
          # :param user_id:
          # :param rank_token: Required for paging through a single feed and can be generated with
              # :meth:`generate_uuid`. You should use the same rank_token for paging through a single user followers.
          # :param kwargs:
              # - **query**: Search within the user followers
              # - **max_id**: For pagination

          raise_if_invalid_rank_token(rank_token)

          endpoint = "friendships/#{user_id}/followers/"
          query_params = {
              'rank_token': rank_token
          }

          query_params.merge!(kwargs)
          check_csrftoken(account.account_session)

          call_api(endpoint, 'GET', authenticated_params, query: query_params, unsigned: true)
        end

        def friendships_show_many(user_ids)
          # Get friendship status with mulitple user ids
          # :param user_ids: list of user ids
          # :return:
          # {
          #     "status": "ok",
          #     "friendship_statuses": {
          #         "123456789": {
          #             "following": false,
          #             "incoming_request": true,
          #             "outgoing_request": false,
          #             "is_private": false
          #         }
          #     }
          # }

          check_csrftoken(account.account_session)

          params = {
            '_uuid': uuid,
            '_csrftoken': csrftoken,
            'user_ids': user_ids.join(',')
          }

          params.merge!(authenticated_params)

          call_api('friendships/show_many/', 'POST', params, unsigned: true)
        end

        def friendships_destroy(user_id)
          # Unfollow a user
          # :param user_id: User id
          # :param kwargs:
          # :return:
          #     .. code-block:: javascript
          #         {
          #             "status": "ok",
          #             "incoming_request": false,
          #             "is_blocking_reel": false,
          #             "followed_by": false,
          #             "is_muting_reel": false,
          #             "outgoing_request": false,
          #             "following": false,
          #             "blocking": false,
          #             "is_private": false
          #         }

          endpoint = "friendships/destroy/#{user_id}/"
          params = { 'user_id': user_id, 'radio_type': radio_type}
          check_csrftoken(account.account_session)
          params.merge!(authenticated_params)

          call_api(endpoint, 'POST', params)
        end
      end
    end
  end
end
