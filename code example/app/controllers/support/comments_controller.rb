# frozen_string_literal: true

module Support
  class CommentsController < InheritedResources::Base
    before_action :authenticate_user!

    belongs_to :ticket, polymorphic: true

    load_and_authorize_resource :ticket
    load_and_authorize_resource through: :ticket

    defaults instance_name: 'support_comment'

    actions :create

    def create
      create! do |success, failure|
        success.html { redirect_to support_ticket_path(parent) }
        failure.html { redirect_to support_ticket_path(parent) }
      end
    end

    private

    def permitted_params
      { support_comment: params.fetch(:support_comment, {}).permit(
        :description, files: []) }
    end

    def build_resource
      super.tap do |attr|
        attr.user = current_user
      end
    end
  end
end
