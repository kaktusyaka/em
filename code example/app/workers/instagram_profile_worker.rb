class InstagramProfileWorker < BaseWorker

  def perform(account_id)
    account = Target.find_by(id: account_id)
    @user = account.user
    @user.sidekiq_jobs.increment

    request = HTTParty.get("#{Figaro.env.INSTAGRAM_BASE_URL}/#{account.username}/?__a=1", headers: headers(@user))

    return unless request.success?

    body = request.parsed_response
    details = body['graphql']['user'] rescue ''

    if details.present?
      account.update_columns(
        biography: details['biography'],
        full_name: details['full_name'],
        profile_pic_url: details['profile_pic_url_hd'],
        follower_count: details['edge_followed_by']['count'],
        follow_count: details['edge_follow']['count'],
        media_count: details['edge_owner_to_timeline_media']['count'],
        is_private: details['is_private'])

      account.update_stats
    end

    account.posts.count.zero? ? account.pull_posts : account.fetch_last_posts

    @user.sidekiq_jobs.decrement

    # disable refresh posts if refresh_period is zero
    return if account.refresh_period.zero?

    account.delay_for(account.refresh_period.minutes).refresh
  end
end
