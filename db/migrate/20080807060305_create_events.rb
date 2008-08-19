class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.references :calendar
      t.string :title, :color, :frequence, :status
      t.text :location, :description
      t.datetime :start_at, :end_at
      t.integer :organizer_id
      t.datetime :until_date
      t.integer :count, :interval
      t.string :by_day, :by_month_day, :by_month

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
