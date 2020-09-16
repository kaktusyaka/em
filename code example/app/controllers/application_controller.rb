# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.orders_path, alert: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  layout :layout_by_resource

  before_action :configure_permitted_parameters, if: :devise_controller?

  around_action :set_time_zone, if: :current_user

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[full_name email password])
    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:full_name, :email, :password, :current_password, :profile_cover,
               :instagram_username, :instagram_password, :avatar, :remove_avatar,
               :time_zone, :allow_email_on_complete_order)
    end
  end

  def after_sign_in_path_for(resource)
    resource.class == AdminUser ? super : orders_path
  end

  def after_sign_up_path_for(_resource)
    orders_path
  end

  private

  def layout_by_resource
    if devise_controller? && !(controller_name == 'registrations' && %w[edit update].include?(action_name))
      'devise'
    else
      'application'
    end
  end

  def set_time_zone
    Time.use_zone(current_user.time_zone) { yield }
  end

  def allow_access_to_instagram?
    authorize! :instagram_section, current_user
  end
end
