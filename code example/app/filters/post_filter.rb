# frozen_string_literal: true

class PostFilter
  def initialize(relation)
    @relation = relation
  end

  private

  def video
    where(__typename: 'GraphVideo')
  end

  def image
    where(__typename: 'GraphImage')
  end

  def slidecard
    where(__typename: 'GraphSidecar')
  end

  def order(direction: :desc)
    order(taken_at_timestamp: direction)
  end

  def where(*condition)
    @relation = @relation.where(*condition)
  end
end
