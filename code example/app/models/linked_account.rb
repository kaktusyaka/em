class LinkedAccount < ApplicationRecord
  belongs_to :user

  has_one_attached :profile_picture

  validates :username, presence: true, uniqueness: { scope: :user_id }
  validates :password, presence: true

  # after_create :pull_user_details

  private

  def pull_user_details
    request = HTTParty.get("#{Figaro.env.INSTAGRAM_BASE_URL}/#{username}/?__a=1")

    return unless request.success?

    body = request.parsed_response
    details = body['graphql']['user'] rescue ''

    if details.present?
      update_columns(
        biography: details['biography'],
        full_name: details['full_name'],
        follower_count: details['edge_followed_by']['count'],
        follow_count: details['edge_follow']['count'],
        media_count: details['edge_owner_to_timeline_media']['count'],
      )
    end
    url = details['profile_pic_url_hd']
    filename = File.basename(URI.parse(url).path)
    file = URI.open(url)
    profile_picture.attach(io: file, filename: filename)
  end
end
