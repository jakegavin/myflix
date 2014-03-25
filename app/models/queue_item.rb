class QueueItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  validates :video_id, presence: true
  validates :user_id, presence: true

  def video_title
    video.title
  end

  def rating
    reviews = Review.where(user_id: user_id, video_id: video_id).order("created_at DESC")
    if reviews.empty?
      return ""
    else
      reviews[0].rating
    end
  end

  def genres
    video.categories
  end
end