module Instagram
  class AccountsController < InheritedResources::Base
    before_action :authenticate_user!
    before_action :allow_access_to_instagram?
    before_action :to_show_page, only: :index

    defaults resource_class: Instagram::Account.friendly, collection_name: 'instagram_accounts', instance_name: 'instagram_account'

    actions :index, :show, :edit, :update, :destroy

    def update
      update! { edit_resource_path }
    end

    private

    def begin_of_association_chain
      current_user
    end

    def to_show_page
      return if collection.blank?

      redirect_to instagram_account_path(collection.first)
    end

    def resource
      get_resource_ivar ||
        set_resource_ivar(
          end_of_association_chain.friendly.send(method_for_find, params[:id])
        )
    end

    def permitted_params
      { instagram_account: params.fetch(:instagram_account, {}).permit(
          :keep_personal_following, :unfollow_auto_number, :following_threshold,
          :unfollow_without_follow_back, :unfollow_after_hours_follow_back,
          :black_list
        )
      }
    end
  end
end
