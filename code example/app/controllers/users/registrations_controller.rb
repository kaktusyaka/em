class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: :create # Change this to be any actions you want to protect.

  protected

  def update_resource(resource, params)
    return super if params["password"]&.present?

    resource.update_without_password(params.except("current_password"))
  end

  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end

  private

  def check_captcha
    return if verify_recaptcha

    self.resource = resource_class.new sign_up_params
    resource.validate # Look for any other validation errors besides Recaptcha
    set_minimum_password_length
    respond_with resource
  end
end
