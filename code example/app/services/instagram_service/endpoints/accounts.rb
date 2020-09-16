# frozen_string_literal: true

module InstagramService
  module Endpoints
    module Accounts
      extend ActiveSupport::Concern

      included do
        def login
          prelogin_params = call_api(
            'si/fetch_headers/',
            'POST',
            { challenge_type: 'signup', guid: generate_uuid(true) },
            return_response: true, unsigned: false
          )

          cookies = parse_cookie(prelogin_params.headers['set-cookie'])

          unless check_csrftoken(cookies)
            raise InstagramService::Errors::Client.new(self, code: 400, error_response: prelogin_params), 'login_required'
          end

          login_params = {
            'device_id': device_id,
            'guid': uuid,
            'adid': ad_id,
            'phone_id': phone_id,
            '_csrftoken': csrftoken,
            'username': username,
            'password': password,
            'login_attempt_count': '0'
          }

          login_response = call_api(
            'accounts/login/', 'POST', login_params, return_response: true, unsigned: false
          )

          cookies = parse_cookie(login_response.headers['set-cookie'])

          if check_csrftoken(cookies).blank?
            raise InstagramService::Errors::Client.new(self, error_response: login_response), 'Unable to get csrf from login.'
          end

          login_response
        end

        def login2fa(identifier, code)
          # Login into account with 2fa enabled

          if identifier.blank? || code.blank?
            raise InstagramService::Errors::ClientLoginRequired.new(self, code: 400), 'login_required'
          end

          check_csrftoken(account.account_session)

          login_params = {
            verification_code: code,
            _csrftoken: csrftoken || account.csrftoken,
            two_factor_identifier: identifier,
            username: username,
            device_id: device_id,
            trust_this_device: '1',
            verification_method: '1'
          }

          login_response = call_api(
            'accounts/two_factor_login/', 'POST', login_params, return_response: true, unsigned: false
          )

          cookies = parse_cookie(login_response.headers['set-cookie'])

          if check_csrftoken(cookies).blank?
            raise InstagramService::Errors::Client.new(self, error_response: login_response), 'Unable to get csrf from login.'
          end

          login_response
        end

        def send_two_factor_login_sms(identifier)
          if identifier.blank?
            raise InstagramService::Errors::Client.new(self), 'identifier is required to send two factor login code'
          end

          check_csrftoken(account.account_session)

          login_params = {
            'device_id': device_id,
            'guid': uuid,
            '_csrftoken': csrftoken,
            'username': username,
            'two_factor_identifier': identifier
          }

          response = call_api(
            'accounts/send_two_factor_login_sms/', 'POST', login_params, return_response: true, unsigned: false
          )

          cookies = parse_cookie(response.headers['set-cookie'])

          if check_csrftoken(cookies).blank?
            raise InstagramService::Errors::Client.new(self, error_response: login_response), 'Unable to get csrf from login.'
          end

          response
        end

        def current_user

          check_csrftoken(account.account_session)
          # Get current user info
          call_api('accounts/current_user/', 'POST', authenticated_params, query: { edit: true } )
        end
      end
    end
  end
end
