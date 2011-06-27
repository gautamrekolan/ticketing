class CreateMonograms < ActiveRecord::Migration
  def self.up
    create_table :monograms do |t|
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :monograms
  end
end
