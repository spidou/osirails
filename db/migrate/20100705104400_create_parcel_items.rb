class CreateParcelItems < ActiveRecord::Migration
  def self.up
    create_table :parcel_items do |t|
      t.references  :parcel, :purchase_order_supply, :problematic_purchase_order_supply
      t.integer     :quantity, :issues_quantity
      t.string      :status
      t.text        :issues_comment
      t.datetime    :reported_at, :issued_at, :cancelled_at
      t.boolean     :must_be_reshipped

      t.timestamps
    end
  end

  def self.down
    drop_table :parcel_items
  end
end

