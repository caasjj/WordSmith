class AddFirebaseId < ActiveRecord::Migration
  def change
    add_column :players, :fb_id, :string 
  end
end
