class FeedSerializer
  include FastJsonapi::ObjectSerializer

  attributes :edge_media_to_comment, :edge_media_preview_like,
             :accessibility_caption, :dimensions

  attribute :typename do |object|
    object['__typename']
  end

  attribute :target do |object|
    {
      username: object.target.username,
      link: Rails.application.routes.url_helpers.target_path(object.target.username),
      profile_pic_url: object.target.profile_pic_url
    }
  end

  attributes :media do |object|
    list = [{ display_url: object.display_url,
              dimensions: object.image_dimensions,
              accessibility_caption: object.accessibility_caption,
              typename: object.__typename, video_url: object.video_url }]
    object.media.each do |m|
      list << { display_url: m.display_url, dimensions: m.image_dimensions,
                accessibility_caption: m.accessibility_caption,
                typename: m.__typename, video_url: m.video_url }
    end
    list.uniq { |e| e[:display_url] }
  end
end
