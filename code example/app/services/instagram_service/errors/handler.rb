# frozen_string_literal: true

module InstagramService
  module Errors
    class Handler
      KNOWN_ERRORS_MAP = [
        { patterns: %w[bad_password invalid_user], error: InstagramService::Errors::ClientLogin },
        { patterns: ['login_required'], error: InstagramService::Errors::ClientLoginRequired },
        {
          patterns: %w[checkpoint_required checkpoint_challenge_required checkpoint_logged_out],
          error: InstagramService::Errors::ClientCheckpointRequired
        },
        { patterns: ['challenge_required'], error: InstagramService::Errors::ClientChallengeRequired },
        { patterns: ['sentry_block'], error: InstagramService::Errors::ClientSentryBlock },
        { patterns: ['feedback_required'], error: InstagramService::Errors::ClientFeedbackRequired },
        { patterns: ['sms_code_validation_code_invalid'], error: InstagramService::Errors::ClientTwoFactorCodeInvalid }
      ].freeze

      def self.process(client, error_response)
        # Tries to process an error meaningfully
        # :param http_error: an instance of compat_urllib_error.HTTPError
        # :param error_response: body of the error response
        error_obj = error_response.parsed_response
        error_msg = error_obj['message']

        if error_response.code == InstagramService::Errors::ClientCodes::REQ_HEADERS_TOO_LARGE
          raise InstagramService::Errors::ClientReqHeadersTooLarge.new(client, code: error_response.code, error_response: error_response), error_msg
        end

        if error_obj.key?('two_factor_required') && error_obj['two_factor_required']
          raise InstagramService::Errors::ClientTwoFactorRequired.new(client, code: error_response.code, error_response: error_response), error_msg
        end

        if error_response.code == InstagramService::Errors::ClientCodes::TOO_MANY_REQUESTS
          raise InstagramService::Errors::ClientThrottled.new(client, code: error_response.code, error_response: error_response), error_msg
        end

        error_message_type = (error_obj['error_type'] || error_obj['message']).to_s

        InstagramService::Errors::Handler::KNOWN_ERRORS_MAP.each do |error_info|
          if error_info[:patterns].include?(error_message_type)
            raise error_info[:error].new(client, code: error_response.code, error_response: error_response), error_msg
          end
        end

        raise InstagramService::Errors::Client.new(client, code: error_response.code, error_response: error_response), error_msg
      end
    end
  end
end
