class Invite < ActiveRecord::Base
  before_create :generate_invite_token  

  belongs_to :inviter, class_name: 'User', foreign_key: 'inviter_id'
  
  validates :inviter, presence: true
  validates :name, presence: true
  validates :email, presence: true
  validates :message, presence: true

  private

  def generate_invite_token
    self.invite_token = SecureRandom.urlsafe_base64
  end
end