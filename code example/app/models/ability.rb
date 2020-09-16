# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can [:read, :index], Support::Ticket do |t|
      t.user_id = user.id
    end

    can :create, Support::Ticket do
      user.id.present?
    end

    can :create, Support::Comment do |c|
      !c.commentable.closed? && c.commentable.user_id == user.id
    end

    can :read, PaymentHistory do |ph|
      ph.user_id == user.id
    end

    can %i[new create], TrialOrder do
      user.phone_number.present? && !user.trial_claimed?
    end

    can :instagram_section, User do
      user.betta_access?
    end
  end
end
