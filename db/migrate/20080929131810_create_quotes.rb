class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.references :order, :creator, :send_quote_method, :order_form_type
      t.string  :status, :reference
      t.float   :carriage_costs, :reduction, :account, :discount, :default => 0
      t.text    :sales_terms
      t.string  :validity_delay_unit
      t.integer :validity_delay
      t.string  :order_form_file_name, :order_form_content_type
      t.integer :order_form_file_size
      t.date    :confirmed_on, :cancelled_on, :sended_on, :signed_on
      
      t.timestamps
    end
    
    add_index :quotes, :reference, :unique => true
  end

  def self.down
    drop_table :quotes
  end
end
