class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :inviter_id
      t.string :name
      t.string :email
      t.text :message
      t.string :invite_token
      t.timestamps
    end
  end
end
