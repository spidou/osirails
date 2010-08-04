class CreateParcelItems < ActiveRecord::Migration
  def self.up
    create_table :parcel_items do |t|
      t.references  :parcel, :purchase_order_supply, :issue_purchase_order_supply, :cancelled_by
      t.integer   :quantity, :issues_quantity
      t.boolean   :must_be_reshipped, :send_back_to_supplier
      t.text      :issues_comment, :cancelled_comment
      t.datetime  :cancelled_at, :issued_at

      t.timestamps
    end
  end

  def self.down
    drop_table :parcel_items
  end
end
