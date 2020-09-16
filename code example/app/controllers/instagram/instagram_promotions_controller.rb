# frozen_string_literal: true

module Instagram
  class InstagramPromotionsController < InheritedResources::Base
    belongs_to :account, parent_class: Instagram::Account.friendly

    defaults resource_class: Instagram::Promotion,
             collection_name: 'promotions'

    actions :all, except: %i[index show]
    custom_actions resource: %i[in_progress pause finish]

    def in_progress
      resource.to_in_progress!
      redirect_to instagram_account_path(id: parent.username), success: 'Selected Promotion has been started'
    end

    def pause
      resource.pause!
      redirect_to instagram_account_path(id: parent.username), success: 'Selected Promotion has been paused'
    end

    def finish
      resource.finish!
      redirect_to instagram_account_path(id: parent.username), success: 'Selected Promotion has been stopped'
    end

    private

    def permitted_params
      { instagram_promotion: params.fetch(:instagram_promotion, {}).permit(
        :target, :account_gender, :skip_used_accounts, :skip_private_accounts,
        :skip_business_accounts, :skip_without_avatar, :max_followers,
        :max_following, :min_posts, :stop_words, :white_words
        )
      }
    end
  end
end
