class CreateCalendars < ActiveRecord::Migration
  def self.up
    create_table :calendars do |t|
      t.references :user
      t.string :name
      t.string :color
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :calendars
  end
end
