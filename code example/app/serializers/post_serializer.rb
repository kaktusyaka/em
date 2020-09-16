class PostSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :edge_media_to_comment, :edge_media_preview_like,
             :display_url, :thumbnail_src, :accessibility_caption, :dimensions

  attribute :thumbnail_resources do |object|
    object.thumbnail_resources.map do |p|
      "#{p['src']} #{p['config_width']}w"
    end.join(', ')
  end

  attribute :typename do |object|
    object['__typename']
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
