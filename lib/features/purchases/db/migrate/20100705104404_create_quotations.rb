class CreateQuotations < ActiveRecord::Migration
  def self.up
    create_table :quotations do |t|
      t.references  :supplier, :creator, :quotation_document, :canceller, :shipper, :quotation_request
      t.integer     :status, :validity_delay
      t.float       :prizegiving, :miscellaneous
      t.string      :reference, :title, :validity_delay_unit
      t.text        :cancellation_comment
      t.date        :received_on, :signed_on, :sent_on
      t.datetime    :cancelled_at, :revoked_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :quotations
  end
end
