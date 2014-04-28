class RenameInviteTokenColumn < ActiveRecord::Migration
  def change
    rename_column :invites, :invite_token, :token
  end
end
