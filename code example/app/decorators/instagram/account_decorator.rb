class Instagram::AccountDecorator < ApplicationDecorator
  delegate_all

  def profile_picture_url
    if model.profile_picture.attached?
      h.url_for(model.profile_picture)
    else
      '/default-avatar.png'
    end
  end

  def follower_count
    "#{h.number_to_human(model.follower_count, units: { thousand: 'k', million: 'm'}, significant: false, precision: 1)} followers"
  end

  def media_count
    h.pluralize(model.media_count, 'post')
  end
end
