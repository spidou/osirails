class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.references :order, :send_quote_method, :order_form_type, :commercial_actor, :quote_contact
      t.string    :status, :reference
      t.float     :carriage_costs, :prizegiving, :deposit, :default => 0
      t.text      :sales_terms
      t.string    :validity_delay_unit
      t.integer   :validity_delay
      t.string    :order_form_file_name, :order_form_content_type
      t.integer   :order_form_file_size
      t.date      :published_on, :sended_on, :signed_on
      t.datetime  :confirmed_at, :cancelled_at
      
      t.timestamps
    end
    
    add_index :quotes, :reference, :unique => true
  end

  def self.down
    drop_table :quotes
  end
end
