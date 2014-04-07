require 'spec_helper'

describe Relationship do
  it { should belong_to :user }
  it { should belong_to :followed_user }

  it { should validate_presence_of (:user_id) }
  it { should validate_presence_of (:followed_id) }


end