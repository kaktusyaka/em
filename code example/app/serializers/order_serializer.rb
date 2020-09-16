class OrderSerializer
  include FastJsonapi::ObjectSerializer

  attributes :link_url, :beginning_quantity, :quantity,
             :created_at

  attribute :service do |obj|
    obj.service.name
  end

  attribute :created_at do |obj|
    obj.created_at.strftime('%d %b %Y %H:%M')
  end

  attribute :status do |obj|
    { value: obj.aasm_state.humanize, class: obj.decorate.status_css_class, title: I18n.t("orders.statuses.#{obj.aasm_state}") }
  end

  attribute :id do |obj|
    obj.identifier
  end
end
