module Instagram
  class AccountSerializer
    include FastJsonapi::ObjectSerializer

    attributes :username, :follower_count

    attributes :profile_pic_url do |obj|
      if obj.profile_picture.attached?
        obj.profile_picture.url
      else
        '/default-avatar.png'
      end
    end

    attribute :follower_count do |obj|
      "#{ActionController::Base.helpers.number_to_human(obj.follower_count, units: { thousand: 'k', million: 'm'}, significant: false, precision: 1)} followers"
    end

    attribute :media_count do |obj|
      ActionController::Base.helpers.pluralize(obj.media_count, 'post')
    end
  end
end
