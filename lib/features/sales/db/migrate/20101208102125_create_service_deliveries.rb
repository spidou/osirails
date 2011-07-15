class CreateServiceDeliveries < ActiveRecord::Migration
  def self.up
    create_table :service_deliveries do |t|
      t.string  :reference, :name
      t.text    :description
      t.float   :cost
      t.decimal :margin, :precision => 65, :scale => 20
      t.float   :vat
      t.string  :time_scale
      t.boolean :pro_rata_billable, :default_pro_rata_billing, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :chekings
  end
end
