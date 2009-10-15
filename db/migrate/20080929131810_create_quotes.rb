class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.references :estimate_step, :user, :send_quote_method, :order_form_type
      t.string  :status, :public_number
      t.float   :carriage_costs,  :default => 0
      t.float   :reduction,       :default => 0
      t.float   :account,         :default => 0
      t.string  :validity_delay_unit
      t.integer :validity_delay
      t.string  :order_form_file_name, :order_form_content_type
      t.integer :order_form_file_size
      t.date    :validated_on, :invalidated_on, :sended_on, :signed_on
      
      t.timestamps
    end
    
    add_index :quotes, :public_number, :unique => true
  end

  def self.down
    drop_table :quotes
  end
end
