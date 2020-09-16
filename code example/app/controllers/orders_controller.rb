class OrdersController < InheritedResources::Base
  defaults finder: :find_by_identifier

  before_action :authenticate_user!
  before_action :allow_trial?, only: :trial

  actions :new, :index
  custom_actions collection: [:trial]

  private

  def begin_of_association_chain
    current_user
  end

  def allow_trial?
    if @user.phone_number.blank?
      redirect_to new_phone_verification_path, success: 'Please verify phone number before claim trial'
    elsif @user.trial_claimed?
      redirect_to orders_path, error: 'Trial is no available for your account'
    end
  end
end
