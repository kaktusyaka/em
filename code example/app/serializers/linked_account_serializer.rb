class LinkedAccountSerializer
  include FastJsonapi::ObjectSerializer

  attributes :username, :profile_pic_url, :posts_count, :biography, :full_name,
             :pulling, :follow_count

  attribute :follower_count do |object|
    "#{ActionController::Base.helpers.number_to_human(object.follower_count, units: { thousand: 'k', million: 'm'}, significant: false, precision: 1)} followers"
  end

  attribute :media_count do |object|
    ActionController::Base.helpers.pluralize(object.media_count, 'post')
  end
end
