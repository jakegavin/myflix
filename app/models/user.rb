class User < ActiveRecord::Base
  has_many :reviews, -> { order("created_at DESC")}
  has_many :queue_items, -> { order("position ASC, created_at DESC")}

  has_many :relationships
  has_many :followed_users, through: :relationships

  has_many :inverse_relationships, class_name: "Relationship", foreign_key: "followed_id"
  has_many :followers, through: :inverse_relationships, source: :user 

  has_secure_password validations: false

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :password, length: { minimum: 5 }, on: :create

  def normalize_queue_items_positions
    queue_items.each_with_index do |item, i|
      item.position = i+1
      item.save!
    end
  end

  def queued_video?(video)
    queue_items.map(&:video).include?(video)
  end

  def follows?(a_user)
    followed_users.include?(a_user)
  end

  def can_follow?(a_user)
    a_user != self && !self.follows?(a_user)
  end
end