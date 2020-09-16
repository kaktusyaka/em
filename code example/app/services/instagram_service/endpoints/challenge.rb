# frozen_string_literal: true

module InstagramService
  module Endpoints
    module Challenge
      extend ActiveSupport::Concern

      # For endpoints in ``/challenge/``.

      included do
        def send_challenge(account_id, identifier, code)

          # Authorize account by solving challenge
          # :param account_id:
          # :param identifier:
          # :param code: code we got from email or sms

          check_csrftoken(account.account_session)

          login_params = {
            'device_id': device_id,
            '_csrftoken': csrftoken,
            'username': username,
            'security_code': code
          }

          response = call_api(
            "challenge/#{account_id}/#{identifier}/", 'POST', login_params, { return_response: true, unsigned: false })

          if check_csrftoken(response.headers['set-cookie']).blank?
            raise InstagramService::Errors::Client.new(self, error_response: response), 'Unable to get csrf from login.'
          end

          response
        end

        def choose_confirm_method(account_id, identifier, confirm_method = 1)
          # Choose whether you want to confirm your account by email or phone number
          # 0 - sms
          # 1 - email

          check_csrftoken(account.account_session)

          params = {
            'device_id': device_id,
            '_csrftoken': csrftoken,
            'username': username,
            'choice': confirm_method
          }

          response = call_api(
            "challenge/#{account_id}/#{identifier}/", 'POST', params, { return_response: true, unsigned: false })
        end
      end
    end
  end
end
