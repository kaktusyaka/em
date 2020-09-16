# frozen_string_literal: true

module Instagram
  module Posts
    class LatestPostsFetcherWorker < BaseWorker
      def perform(account_id, user_id) #:nodoc:
        @user = User.find(user_id)
        account = Target.find_by(id: account_id)

        account.pulling_in_progess

        params =
          { query_id: Figaro.env.INSTAGRAM_QUERY_ID, id: account.pk, first: 30 }
        posts = pull_posts(params)

        posts['edge_owner_to_timeline_media']['edges'].each do |post|
          post = post['node']

          break if Post.find_by(pk_id: post['id'])

          account.add_post(post)
        end

        account.pulling_in_progess false
        @user.sidekiq_jobs.decrement
      end
    end
  end
end
