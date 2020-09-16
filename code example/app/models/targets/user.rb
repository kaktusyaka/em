class Targets::User < Target
  validates :username, presence: true, length: { maximum: 255 }

  after_create :pull_user_details

  def pull_user_details
    j = InstagramProfileWorker.perform_async(id)
    update_columns jid: j
  end
end
