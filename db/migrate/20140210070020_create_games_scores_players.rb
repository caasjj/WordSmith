class CreateGamesScoresPlayers < ActiveRecord::Migration
  def change

    create_table :players do |t|
      t.string :username
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :token
      t.string :salt
      t.string :password_hash
      t.timestamps
    end

    create_table :games do |t|
      t.string :title
      t.timestamps
    end

    create_table :scores do |t|
      t.belongs_to :game
      t.belongs_to :player
      t.integer :points
      t.timestamps
    end
  end
end
