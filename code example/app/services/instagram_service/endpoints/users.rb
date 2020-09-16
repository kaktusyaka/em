# frozen_string_literal: true

module InstagramService
  module Endpoints
    module Users
      extend ActiveSupport::Concern

      included do
        def user_info(user_id)
          # Get user info for a specified user id
          # :param user_id:
          check_csrftoken(account.account_session)
          call_api("users/#{user_id}/info/", 'GET', authenticated_params, unsigned: true)
        end

        def user_detail_info(user_id)
          # Get user info for a specified user id
          # :param user_id:
          check_csrftoken(account.account_session)
          call_api("users/#{user_id}/full_detail_info/", 'GET', authenticated_params, unsigned: true)
        end

        def username_info(user_name)
          # Get user info for a specified user name
          # :param user_name:
          check_csrftoken(account.account_session)
          call_api("users/#{user_name}/usernameinfo/", 'GET', authenticated_params, unsigned: true)
        end

        def user_following(user_id)
          # Get user followings
          # :param user_id:
          # :param rank_token: Required for paging through a single feed and can be generated with
              # :meth:`generate_uuid`. You should use the same rank_token for paging through a single user following.
          # :param kwargs:
              # - **query**: Search within the user following
              # - **max_id**: For pagination

          # raise_if_invalid_rank_token(rank_token)

          check_csrftoken(account.account_session)

          endpoint = "friendships/#{user_id}/following/"
          # query_params = {
          #     'rank_token': rank_token,
          # }
          # query_params.update(kwargs)
          call_api(endpoint, 'GET', authenticated_params, unsigned: true)
        end
      end
    end
  end
end
