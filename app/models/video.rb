class Video < ActiveRecord::Base
  has_many :video_categories
  has_many :categories, through: :video_categories
  has_many :reviews, -> { order("created_at DESC") }
  has_many :queue_items
  
  validates_presence_of :title, :description

  def self.search_by_title(search_term)
    return [] if search_term.empty?
    where('title LIKE ?', "%#{search_term}%").order("created_at DESC")
  end

  def average_rating
    return 'N/A' if reviews.empty?
    sum = reviews.reload.inject(0) { |memo, review| memo + (review.rating.nil? ? 2.5 : review.rating) }
    (sum.to_f / reviews.size.to_f).round(1)
  end

end