class Invite < ActiveRecord::Base
  include Tokenable

  before_create :generate_token

  belongs_to :inviter, class_name: 'User', foreign_key: 'inviter_id'

  validates :inviter, presence: true
  validates :name, presence: true
  validates :email, presence: true
  validates :message, presence: true
end
