class CreateQuotationRequests < ActiveRecord::Migration
  def self.up
    create_table :quotation_requests do |t|
      t.references  :creator, :employee, :canceller, :parent, :similar, :supplier, :supplier_contact, :revoker
      t.integer     :status
      t.string      :reference, :title
      t.text        :cancellation_comment
      t.datetime    :cancelled_at, :confirmed_at, :revoked_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :quotation_requests
  end
end
