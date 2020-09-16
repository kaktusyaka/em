# frozen_string_literal: true

class Api::OrdersController < Api::ApiController
  inherit_resources

  actions :create
  custom_actions collection: %i[history link_preview]

  respond_to :json

  def create
    create! do |_success, failure|
      failure.json do
        render json: { errors: resource.errors.to_hash(true).values.flatten }, status: 422
      end
    end
  end

  def history
    query = JSON.parse(params[:query])
    page = begin
             (query['offset'] / query['limit'] + 1)
           rescue StandardError
             1
           end

    p, orders = pagy(current_user.orders.order(id: :desc),
                     items: query['limit'], page: page)

    render json: { orders: OrderSerializer.new(orders).serializable_hash,
                   total: p.count }
  end

  def link_preview
    response =
      HTTParty.get("https://#{URI(params[:url]).host}#{URI(params[:url]).path}?__a=1")
              .parsed_response

    if response['logging_page_id'] ## user
      render json: { images: [response['graphql']['user']['profile_pic_url']], title: response['graphql']['user']['full_name'], url: params[:url], description: response['graphql']['user']['biography'] }
    elsif response['graphql'] ## post
      render json: { images: [response['graphql']['shortcode_media']['display_url']], title: nil, url: params[:url], description: (response['graphql']['shortcode_media']['edge_media_to_caption']['edges'].first['node']['text'] rescue '') }
    else
      render status: 422
    end
  end

  private

  def begin_of_association_chain
    current_user
  end

  def permitted_params
    { order: params.fetch(:order, {}).permit(
      :service_id, :link_url, :comments, :quantity, :check_timer, :timer_likes,
      :timer_interval
    ) }
  end
end
