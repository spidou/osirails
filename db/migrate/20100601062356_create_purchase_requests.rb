class CreatePurchaseRequests < ActiveRecord::Migration
  def self.up
    create_table  :purchase_requests do |t|
      t.integer   :user_id
      t.integer   :employee_id
      t.integer   :service_id
      t.string    :reference
      t.datetime  :cancelled_at
      t.string    :cancelled_comment
      t.integer   :cancelled_by
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_requests
  end
end
