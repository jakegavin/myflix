class QueueItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  validates :video_id, presence: true
  validates :user_id, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  delegate :title, to: :video, prefix: :video

  def rating
    return "" if review.nil?
    review.rating
  end

  def rating=(new_rating)
    new_rating = nil if new_rating == ""
    if review
      review.update_columns(rating: new_rating)
    elsif !new_rating.nil?
      new_review = Review.new(user: user, video: video, rating: new_rating)
      new_review.save!(validate: false)
    end
  end

  def genres
    video.categories
  end

  def review
    @review ||= Review.where(user_id: user_id, video_id: video_id).order("created_at DESC").first
  end
end