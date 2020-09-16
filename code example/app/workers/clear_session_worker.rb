class ClearSessionWorker
  include Sidekiq::Worker

  def perform
    Session.sweep
  end
end
