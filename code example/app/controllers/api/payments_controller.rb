# frozen_string_literal: true

class Api::PaymentsController < Api::ApiController
  skip_before_action :authenticate_user!, only: :webhooks

  before_action :validate_stripe_event, only: :webhooks

  def history
    query = JSON.parse(params[:query])
    page = begin
             (query['offset'] / query['limit'] + 1)
           rescue StandardError
             1
           end

    p, transactions = pagy(current_user.payment_history.confirmed.desc,
                     items: query['limit'], page: page)

    render json: {
      transactions: PaymentHistorySerializer.new(transactions).serializable_hash,
      total: p.count
    }
  end

  def pay
    unless params[:amount].to_f.positive?
      render json: { message: 'Amount should be more than 0' }, status: 422
      return
    end

    ph = current_user.payment_history.create(amount: params[:amount],
                                             payment_system: 'Stripe',
                                             confirmed: false)

    payment = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        name: 'The SMM Tools',
        description: 'Top up balance',
        amount: (params[:amount].to_f * 100).to_i,
        currency: 'usd',
        quantity: 1
      }],
      customer_email: current_user.email,
      submit_type: 'pay',
      success_url: success_payment_url(id: ph.identifier),
      cancel_url: cancel_payments_url
    )

    ph.update_columns(transaction_id: payment.payment_intent)

    render json: { checkout_session_id: payment.id }
  end

  def webhooks
    case @event.type
    when 'payment_intent.succeeded'
      sleep 1
      payment_intent = @event.data.object
      ph = PaymentHistory.find_by(transaction_id: payment_intent['id'])
      ph.update(confirmed: true) if params['payment']['data']['object']['status'] == 'succeeded'
      render body: nil, status: 200

    when 'payment_intent.failed'
      payment_intent = @event.data.object
      ph = PaymentHistory.find_by(transaction_id: payment_intent['id'])
      ph.destroy
      render body: nil, status: 400

    end
  end

  def check
    render json: { confirmed: current_user.payment_history.find_by(identifier: params[:id])&.confirmed }
  end

  private

  def validate_stripe_event
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    @event = nil

    begin
      @event = Stripe::Webhook.construct_event(
        payload, sig_header,
        Rails.application.credentials.stripe.dig(:webhooks_signature)
      )
    rescue JSON::ParserError
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError
      # Invalid signature
      status 400
      return
    end
  end
end
