# frozen_string_literal: true

module InstagramService
  module Errors
    # Generic error class, catch-all for most client issues.
    class Client < StandardError
      attr_reader :object
      attr_reader :args

      def initialize(object, args = {})
        @object = object
        @args = args
      end
    end
  end
end
