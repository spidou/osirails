class CreateTools < ActiveRecord::Migration
  def self.up
    create_table :tools do |t|
      t.references :service, :job, :employee, :supplier
      t.string  :name, :serial_number, :type
      t.text    :description
      t.date    :purchase_date
      t.float   :purchase_price
      
      t.timestamps
    end
  end

  def self.down
    drop_table :tools
  end
end
