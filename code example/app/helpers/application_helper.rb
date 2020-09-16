# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def body_attributes
    { class: body_class, id: body_id }
  end

  def body_class
    controller_name.dasherize
  end

  def body_id
    "#{controller_name.dasherize}-#{action_name.dasherize}"
  end

  def flash_class(level)
    case level
    when 'notice' then 'alert alert-info'
    when 'success' then 'alert alert-green'
    when 'error' then 'alert alert-danger'
    when 'alert' then 'alert alert-warning'
    end
  end

  def rich_text_area_tag(name, value = nil, options = {})
    options = options.symbolize_keys

    options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
    options[:class] ||= 'trix-content'

    options[:data] ||= {}
    options[:data][:direct_upload_url] = main_app.rails_direct_uploads_url
    options[:data][:blob_url_template] = main_app.rails_service_blob_url(':signed_id', ':filename')

    editor_tag = content_tag('trix-editor', '', options)
    input_tag = hidden_field_tag(name, value, id: options[:input])

    input_tag + editor_tag
  end

  def number_to_currency(number, options = {})
    Money.new(number.to_f * 100, options[:unit] || 'USD').format(sign_before_symbol: true)
  end

  def vue_flash_notifications
    if flash.any?
      capture do
        content_tag(:div, nil, id: :flash_messages, data: { messages: flash.map { |key, value| { text: value, type: key } } })
      end.html_safe
    end
  end
end
