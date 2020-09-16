class PaymentHistorySerializer
  include FastJsonapi::ObjectSerializer

  attribute :id do |obj|
    obj.identifier
  end

  attribute :created_at do |obj|
    obj.created_at.strftime('%d %b %Y %H:%M')
  end

  attribute :amount do |obj|
    ApplicationController.helpers.number_to_currency(obj.amount)
  end

  attribute :operation do |obj|
    if obj.order_id.present?
      "Order ID: #{obj.order&.identifier}"
    else
      "#{obj.payment_system} - #{obj.transaction_id}"
    end
  end

  attribute :details do |obj|
    if obj.order_id.present?
      "#{obj.order&.service&.name} (Quantity: #{obj.order&.quantity})"
    else
      'Top up balance'
    end
  end
end
