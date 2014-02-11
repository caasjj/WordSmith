class CreateDictionary < ActiveRecord::Migration
  def change
  	create_table :dict do |t|
  		t.string :word
  		t.string :points
  	end
  end
end
