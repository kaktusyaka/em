# frozen_string_literal: true

class Target < ApplicationRecord #:nodoc:
  extend FriendlyId
  friendly_id :username

  REFRESH_PERIOD_LIST = { 0 => 'Disable',
                          15 => 'Every 15 minutes',
                          30 => 'Every 30 minutes',
                          60 => 'Every hour',
                          180 => 'Every 3 hours',
                          1440 => 'Every day' }.freeze

  has_many :target_to_users
  has_many :users, through: :target_to_users, dependent: :destroy

  has_many :posts, -> { where parent: nil }
  has_many :statistics, as: :statisticable, dependent: :destroy

  after_destroy :kill_jobs, :destroy_posts

  def pull_posts
    j = InstagramPostsWorker.perform_in(2.seconds, id, user.id)
    update_columns jid: j
  end

  def user
    users.shuffle.first
  end

  def add_post(data)
    posts.create!(
      __typename: data['__typename'],
      pk_id: data['id'],
      shortcode: data['shortcode'],
      comment: (begin
                  data['edge_media_to_caption']['edges'].first['node']['text']
                rescue StandardError
                  ''
                end),
      taken_at_timestamp:
        DateTime.strptime(data['taken_at_timestamp'].to_s, '%s'),
      display_url: data['display_url'],
      location: data['location'].present? ? data['location'] : {},
      thumbnail_src: data['thumbnail_src'],
      thumbnail_resources: data['thumbnail_resources'],
      is_video: data['is_video'],
      edge_media_to_comment: data['edge_media_to_comment']['count'],
      edge_media_preview_like: data['edge_media_preview_like']['count'],
      accessibility_caption: data['accessibility_caption'],
      video_url: data['video_url'],
      video_view_count: data['video_view_count'].to_i,
      dimensions: data['dimensions']
    )
  end

  def pulling_in_progess(state = true)
    update_columns pulling: state
  end

  def refresh
    pull_user_details
    fetch_last_posts
  end

  def update_stats
    statistics.create!(posts: media_count, follower: follower_count,
                       follow: follow_count)
  end

  def fetch_last_posts
    user.sidekiq_jobs.increment
    Instagram::Posts::LatestPostsFetcherWorker.perform_in(
      user.sidekiq_jobs.value.to_i.seconds, id, user.id
    )
  end

  def kill_jobs
    return if jid.blank?

    queue = Sidekiq::Queue.new
    queue.each do |job|
      job.delete if job.jid == jid
    end
    Sidekiq::ScheduledSet.new.find_job(jid)&.delete
  end

  private

  def destroy_posts
    Post.where(id: post_ids).delay.destroy_all
  end
end
