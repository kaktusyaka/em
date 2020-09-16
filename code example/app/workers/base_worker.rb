# frozen_string_literal: true

class BaseWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def headers(user)
    { 'Cookie' => user.instagram_session }
    # 'Accept' => IgApi::Constants::HEADER[:accept],
    # 'Accept-Encoding' => IgApi::Constants::HEADER[:encoding],
    # 'Accept-Language' => 'en-US',
    # 'X-IG-Capabilities' => IgApi::Constants::HEADER[:capabilities],
    # 'X-IG-Connection-Type' => IgApi::Constants::HEADER[:type] }
  end

  def pull_posts(params)
    sleep 0.5
    response = HTTParty.get("#{Figaro.env.INSTAGRAM_BASE_URL}/graphql/query",
                            query: params, headers: headers(@user))
    if response.code == 200
      response.parsed_response['data']['user']
    elsif response.code == 429
      raise 'Code 429'
    end
  end
end
