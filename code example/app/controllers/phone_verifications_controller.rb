class PhoneVerificationsController < ApplicationController

  before_action :authenticate_user!
  before_action :to_challenge_page, only: %i[new create]
  before_action :to_new_page, only: %i[challenge verify]
  before_action :set_user

  def new; end

  def create
    session[:phone_number] = params[:phone_number]
    session[:country_code] = (Phoner::Phone.parse(params[:phone_number]).country_code rescue nil)
    @user.temp_phone_number = params[:phone_number]
    if !verify_recaptcha(model: @user) || !@user.valid?
      render action: :new
      return
    end

    response = Authy::PhoneVerification.start(
      via: 'sms',
      country_code: session[:country_code],
      phone_number: session[:phone_number]
    )
    if response.ok?
      @user.update_columns(temp_phone_number: params[:phone_number],
                                  set_temp_phone_number: Time.now)
      redirect_to challenge_phone_verifications_path
    else
      @user.errors.add(:phone_number, 'is invalid')
      render action: :new
    end
  end

  def challenge; end

  def verify
    if verify_recaptcha(model: @user)
      response = Authy::PhoneVerification.check(verification_code: params[:code], country_code: session[:country_code], phone_number: session[:phone_number])
      if response.ok?
        session[:phone_number] = nil
        session[:country_code] = nil
        current_user.update phone_number: current_user.temp_phone_number, temp_phone_number: nil, set_temp_phone_number: nil
        redirect_to new_trial_order_path
      else
        render action: :challenge
      end
    else
      render action: :challenge
    end
  end

  private

  def to_challenge_page
    if current_user.set_temp_phone_number && current_user.set_temp_phone_number + 15.minutes > Time.now
      redirect_to challenge_phone_verifications_path
    end
  end

  def to_new_page
    if current_user.set_temp_phone_number.blank? || current_user.set_temp_phone_number + 15.minutes < Time.now
      redirect_to new_phone_verification_path
    end
  end

  def set_user
    @user = current_user
  end

  def to_order_page
    redirect_to orders_path, notice: 'Phone Number has been verified' if current_user.phone_number.present?
  end
end
