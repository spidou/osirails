class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.references :calendar, :event_category, :organizer
      t.string    :title, :color, :frequence, :status
      t.boolean   :full_day, :default => false, :null => false
      t.text      :location, :description, :link
      t.integer   :interval, :default => 1, :null => false
      t.integer   :count
      t.string    :by_day, :by_month_day, :by_month
      t.datetime  :start_at, :end_at
      t.date      :until_date
      
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
