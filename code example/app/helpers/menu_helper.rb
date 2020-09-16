# frozen_string_literal: true

module MenuHelper
  def targets_page?
    controller_name == 'targets' && action_name == 'index'
  end

  def feed_page?
    controller_name == 'targets' && action_name == 'feed'
  end

  def public_pricing_page?
    params[:id] == 'prices' && controller_name == 'pages'
  end

  def public_faq_page?
    params[:id] == 'faq' && controller_name == 'pages'
  end

  def public_contact_us_page?
    controller_name == 'pages' && %w[contact_us contact_us_submit].include?(action_name)
  end

  def faq_page?
    false
  end

  def support_page?
    params[:id] == 'support' && controller_name == 'pages'
  end

  def orders_page?
    controller_name == 'orders'
  end

  def support_pages?
    controller_path.include?('support') && action_name != 'prices'
  end

  def new_support_requests_history_page?
    controller_name == 'tickets' && %w[new create].include?(action_name)
  end

  def support_requests_history_page?
    controller_name == 'tickets' && !%w[new create].include?(action_name)
  end

  def prices_internal_page?
    controller_name == 'support' && action_name == 'prices'
  end

  def faq_internal_page?
    controller_name == 'support' && action_name == 'faq'
  end

  def new_order_page?
    controller_name == 'orders' && action_name == 'new'
  end

  def order_history_page?
    controller_name == 'orders' && action_name == 'history'
  end

  def payments_page?
    controller_name == 'payments'
  end

  def instagram_page?
    controller_path.include?('instagram')
  end

  def instagram_account_show_page?
    instagram_page? && action_name == 'show'
  end
end
