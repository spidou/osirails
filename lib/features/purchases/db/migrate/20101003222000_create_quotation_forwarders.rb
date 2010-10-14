class CreateQuotationForwarders < ActiveRecord::Migration
  def self.up
    create_table :quotation_forwarders do |t|
      t.references :quotation, :forwarder
      
      t.timestamps
    end
    
    add_index :quotation_forwarders, [:quotation_id, :forwarder_id], :unique => true
  end
  
  def self.down
    drop_table :quotation_forwarders
  end
end
