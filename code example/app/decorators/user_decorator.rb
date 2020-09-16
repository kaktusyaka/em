class UserDecorator < ApplicationDecorator
  delegate_all

  def avatar
    model.avatar.attached? ? h.url_for(model.avatar) : '/default-avatar.png'
  end

  def profile_cover
    model.profile_cover.attached? ? h.url_for(model.profile_cover) : '/profile-cover.jpg'
  end
end
