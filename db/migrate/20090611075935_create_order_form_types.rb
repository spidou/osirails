class CreateOrderFormTypes < ActiveRecord::Migration
  def self.up
    create_table :order_form_types do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :order_form_types
  end
end
