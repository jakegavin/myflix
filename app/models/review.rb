class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  validates_presence_of :user_id, :video_id, :rating, :text

  delegate :title, to: :video, prefix: :video
  
end