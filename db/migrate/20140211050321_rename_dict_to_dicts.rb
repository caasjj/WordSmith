class RenameDictToDicts < ActiveRecord::Migration
  def change
    rename_table :dict, :dicts
  end
end
