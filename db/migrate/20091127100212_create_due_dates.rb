class CreateDueDates < ActiveRecord::Migration
  def self.up
    create_table :due_dates do |t|
      t.references :invoice
      t.date  :date
      t.float :net_to_paid
      
      t.timestamps
    end
  end

  def self.down
    drop_table :due_dates
  end
end
