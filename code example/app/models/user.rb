# frozen_string_literal: true

class User < ApplicationRecord
  include Redis::Objects
  counter :sidekiq_jobs

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :async,
         :recoverable, :rememberable, :validatable, :trackable, :omniauthable,
         omniauth_providers: %i[facebook instagram google_oauth2]

  has_many :star_now_accounts, dependent: :destroy, class_name: 'StarNow::Account'
  has_many :star_now_jobs, through: :star_now_accounts, class_name: 'StarNow::Job'

  has_many :instagram_accounts, dependent: :destroy, class_name: 'Instagram::Account'

  has_many :omniauth_providers, dependent: :destroy

  # has_many :posts, through: :targets
  has_many :orders, dependent: :destroy
  has_many :payment_history, dependent: :destroy
  has_many :tickets, dependent: :destroy, class_name: 'Support::Ticket'
  has_many :comments, through: :tickets, class_name: 'Support::Comment', dependent: :destroy
  has_many :trial_orders, dependent: :destroy

  has_one_attached :avatar
  has_one_attached :profile_cover

  attr_accessor :remove_avatar
  attr_accessor :remove_profile_cover

  validates :full_name, format: { with: /\A[^0-9`!@#\$%\^&*+_=]+\z/ },
                        length: { maximum: 255 }
  validates :email, 'valid_email_2/email': { disposable: true }
  validates :phone_number, uniqueness: true, allow_blank: true

  validate :phone_number_should_be_uniq

  after_create :signup_track, :send_welcome_email
  after_save :purge_avatar, if: :remove_avatar
  after_save :purge_profile_cover, if: :remove_profile_cover

  def after_database_authentication
    Sqreen.auth_track(true, email: email)
  end

  class << self
    def from_omniauth(auth)
      if (op = OmniauthProvider.find_by(provider: auth.provider, uid: auth.uid))
        Sqreen.auth_track(true, email: op.user.email)
        return op.user
      end

      if (user = User.find_by(email: auth.info.email))
        omniauth_providers.create(provider: auth.provider, uid: auth.uid)
        Sqreen.auth_track(true, email: user.email)
        return user
      end

      user = User.new(email: auth.info.email,
                      password: Devise.friendly_token[0, 20],
                      full_name: auth.info.name)
      user.save
      user.omniauth_providers.create(provider: auth.provider, uid: auth.uid)
      user

      # where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      #   user.email = auth.info.email
      #   user.password = Devise.friendly_token[0, 20]
      #   user.full_name = auth.info.name   # assuming the user model has a name
      #   # user.image = auth.info.image # assuming the user model has an image
      #   # If you are using confirmable and the provider(s) you use validate emails,
      #   # uncomment the line below to skip the confirmation emails.
      #   user.skip_confirmation!
      # end
    end

    def new_with_session(params, session)
      super.tap do |user|
        if (data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info'])
          user.email = data['email'] if user.email.blank?
        end
      end
    end
  end

  def reset_password
    Sqreen.track('app.reset_password_request', user_identifiers: email)
    super
  end

  private

  def signup_track
    Sqreen.signup_track(email: email)
  end

  def purge_avatar
    avatar.purge_later
  end

  def purge_profile_cover
    profile_cover.purge_later
  end

  def send_welcome_email
    UserMailer.delay.welcome_email(self)
  end

  def phone_number_should_be_uniq
    return if temp_phone_number.blank?

    errors.add(:phone_number, 'should be uniq') if User.where.not(id: id).find_by(phone_number: temp_phone_number).present?
  end
end
