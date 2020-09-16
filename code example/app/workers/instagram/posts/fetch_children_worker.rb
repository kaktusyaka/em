# frozen_string_literal: true

module Instagram
  module Posts
    class FetchChildrenWorker < BaseWorker
      def perform(post_id, user_id)
        post = Post.find(post_id)
        @user = User.find(user_id)

        response = fetch_posts(post)
        raise 'Code 429' if response.code == 429

        posts = response.parsed_response

        posts['graphql']['shortcode_media']['edge_sidecar_to_children']['edges'].each do |p|
          p = p['node']
          next if Post.find_by(pk_id: p['id'])

          post.add_media(p)
        end
        @user.sidekiq_jobs.decrement
        post.fetch_sidecar(48.hours, @user) if post.media.pluck(:__typename).include?('GraphVideo')
      end

      private

      def fetch_posts(post)
        HTTParty.get(
          "#{Figaro.env.INSTAGRAM_BASE_URL}/p/#{post.shortcode}/?__a=1",
          headers: headers(@user)
        )
      end
    end
  end
end
