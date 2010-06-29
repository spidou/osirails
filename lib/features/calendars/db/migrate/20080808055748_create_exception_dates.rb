class CreateExceptionDates < ActiveRecord::Migration
  def self.up
    create_table :exception_dates do |t|
      t.references :event
      t.date :date
    end
  end

  def self.down
    drop_table :exception_dates
  end
end
