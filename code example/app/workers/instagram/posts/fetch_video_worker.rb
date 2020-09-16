# frozen_string_literal: true

module Instagram
  module Posts
    class FetchVideoWorker < BaseWorker
      def perform(post_id, user_id)
        post = Post.find(post_id)
        @user = User.find(user_id)

        response = fetch_post(post)
        raise 'Code 429' if response.code == 429

        posts = response.parsed_response

        p = posts['graphql']['shortcode_media']

        return unless Post.find_by(pk_id: p['id'])

        post.update_columns(
          video_url: p['video_url'],
          video_view_count: p['video_view_count']
        )

        @user.sidekiq_jobs.decrement

        post.fetch_video(48.hours, @user) if post.parent.blank?
      end

      private

      def fetch_post(post)
        HTTParty.get(
          "#{Figaro.env.INSTAGRAM_BASE_URL}/p/#{post.shortcode}/?__a=1",
          headers: headers(@user)
        )
      end
    end
  end
end
