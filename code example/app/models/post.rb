class Post < ApplicationRecord
  belongs_to :target, counter_cache: true, optional: true
  belongs_to :parent, class_name: 'Post', foreign_key: 'parent_id', optional: true

  has_many :media, class_name: 'Post', foreign_key: 'parent_id'
  has_many :statistics, as: :statisticable

  serialize :location, Hash
  serialize :thumbnail_resources, Array
  serialize :display_resources, Array
  serialize :dimensions, Hash

  after_create :pull_children_posts
  after_destroy :kill_jobs

  scope :only_parents, -> { where parent_id: nil }

  def pull_children_posts
    return if __typename == 'GraphImage'

    u = target&.user || parent.target.user

    u.sidekiq_jobs.increment

    if __typename == 'GraphSidecar'
      fetch_sidecar(u.sidekiq_jobs.value.to_i.seconds, u)
    else
      return if video_url.present?

      fetch_video(u.sidekiq_jobs.value.to_i.seconds, u)
    end
  end

  def add_media(data)
    media.create!(
      :__typename => data['__typename'],
      pk_id: data['id'],
      shortcode: data['shortcode'],
      display_url: data['display_url'],
      display_resources: data['display_resources'],
      accessibility_caption: data['accessibility_caption'],
      is_video: data['is_video'],
      video_url: data['video_url'],
      dimensions: data['dimensions']
    )
  end

  def image_dimensions
    (__typename == 'GraphVideo' && parent.blank?) ? video_dimesions : photo_dimensions
  end

  def fetch_video(delay_t, u)
    j = Instagram::Posts::FetchVideoWorker.perform_in(delay_t, id, u.id)
    update_columns jid: j
    u.sidekiq_jobs.increment
  end

  def fetch_sidecar(delay_t, u)
    j = Instagram::Posts::FetchChildrenWorker.perform_in(delay_t, id, u.id)
    update_columns jid: j
    u.sidekiq_jobs.increment
  end

  private

  def kill_jobs
    return if jid.blank?

    queue = Sidekiq::Queue.new
    queue.each do |job|
      job.delete if job.jid == jid
    end
    Sidekiq::ScheduledSet.new.find_job(jid)&.delete
  end

  def video_dimesions
    if dimensions['height'] > dimensions['width']
      { width: 400, height: (dimensions['height'].to_f / dimensions['width']) * 400 }
    else
      { width: 600, height: 600.0 / ( dimensions['width'].to_f / dimensions['height'] ) + 5 }
    end
  end

  def photo_dimensions
    if dimensions['width'] == dimensions['height']
      { width: 600, height: 600 }
    elsif dimensions['height'] > dimensions['width']
      { width: 600, height: (dimensions['height'].to_f / dimensions['width']) * 600 }
    else
      { width: 600, height: 600.0 / ( dimensions['width'].to_f / dimensions['height'] ) + 5 }
    end
  end
end
