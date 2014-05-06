class Video < ActiveRecord::Base
  has_many :video_categories
  has_many :categories, through: :video_categories
  has_many :reviews, -> { order("created_at DESC") }
  has_many :queue_items

  mount_uploader :large_cover, LargeCoverUploader
  mount_uploader :small_cover, SmallCoverUploader
  
  validates_presence_of :title, :description

  def self.search_by_title(search_term)
    return [] if search_term.empty?
    where('title LIKE ?', "%#{search_term}%").order("created_at DESC")
  end

  def average_rating
    clean_reviews = reviews.reload.where('rating IS NOT NULL')
    return 'N/A' if clean_reviews.empty?
    ratings = clean_reviews.map(&:rating)
    (ratings.sum.to_f / clean_reviews.size.to_f).round(1)
  end
end