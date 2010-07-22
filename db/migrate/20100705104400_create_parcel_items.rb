class CreateParcelItems < ActiveRecord::Migration
  def self.up
    create_table :parcel_items do |t|
      t.references  :parcel, :purchase_order_supply, :issue_purchase_order_supply
      t.integer     :quantity, :issues_quantity, :cancelled_by
      t.string      :status
      t.text        :issues_comment, :cancelled_comment
      t.datetime    :cancelled_at
      t.date        :issued_at
      t.boolean     :must_be_reshipped, :send_back_to_supplier

      t.timestamps
    end
  end

  def self.down
    drop_table :parcel_items
  end
end

