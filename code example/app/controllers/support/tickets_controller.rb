# frozen_string_literal: true

module Support
  class TicketsController < InheritedResources::Base
    before_action :authenticate_user!

    load_and_authorize_resource

    defaults instance_name: 'support_ticket'

    has_scope :opened, type: :boolean
    has_scope :closed, type: :boolean
    has_scope :waiting, type: :boolean
    has_scope :answered, type: :boolean

    actions :index, :show, :new, :create

    def show
      show! do |f|
        f.html do
          @comments =
            resource.comments.includes(:user)
                    .with_rich_text_description_and_embeds
        end
      end
    end

    private

    def begin_of_association_chain
      current_user
    end

    def permitted_params
      { support_ticket: params.fetch(:support_ticket, {}).permit(
        :subject, :description, files: []) }
    end
  end
end
