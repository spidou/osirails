class CreateQuotationForwarders < ActiveRecord::Migration
  def self.up
    create_table :quotation_forwarders do |t|
      t.references :quotation, :forwarder
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :quotation_forwarders
  end
end
