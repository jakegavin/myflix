class QueueItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  validates :video_id, presence: true
  validates :user_id, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  delegate :title, to: :video, prefix: :video

  def rating
    review = Review.where(user_id: user_id, video_id: video_id).order("created_at DESC").first
    return "" if review.nil?
    review.rating
  end

  def genres
    video.categories
  end
end