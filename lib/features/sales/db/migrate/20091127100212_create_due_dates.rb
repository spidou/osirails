class CreateDueDates < ActiveRecord::Migration
  def self.up
    create_table :due_dates do |t|
      t.references :invoice
      t.date    :date
      t.decimal :net_to_paid, :precision => 65, :scale => 20
      
      t.timestamps
    end
  end

  def self.down
    drop_table :due_dates
  end
end
