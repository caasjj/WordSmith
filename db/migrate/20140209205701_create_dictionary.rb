class CreateDictionary < ActiveRecord::Migration
  def change
  	create_table :dictionary do |t|
  		t.string :word
  		t.string :points
  	end
  end
end