class AddVideoUrlToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :url, :string
  end
end
