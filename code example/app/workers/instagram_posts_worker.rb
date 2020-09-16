class InstagramPostsWorker < BaseWorker

  def perform(account_id, user_id)
    account = Target.find_by(id: account_id)

    @user = account.users.find_by(id: user_id)
    @user.sidekiq_jobs.increment

    has_next_page = true
    end_cursor = nil

    while has_next_page do
      params = { query_id: Figaro.env.INSTAGRAM_QUERY_ID, id: account.pk, first: 30 }
      params.merge!(after: end_cursor) if end_cursor
      posts = pull_posts(params)

      posts['edge_owner_to_timeline_media']['edges'].each do |post|
        post = post['node']

        next if Post.find_by(pk_id: post['id'])

        account.add_post(post)
      end

      has_next_page = posts['edge_owner_to_timeline_media']['page_info']['has_next_page']
      end_cursor = posts['edge_owner_to_timeline_media']['page_info']['end_cursor']
    end

    account.pulling_in_progess false
    @user.sidekiq_jobs.decrement
  end
end
