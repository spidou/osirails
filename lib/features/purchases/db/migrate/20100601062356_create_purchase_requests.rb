class CreatePurchaseRequests < ActiveRecord::Migration
  def self.up
    create_table  :purchase_requests do |t|
      t.references  :user, :employee, :service, :cancelled_by      
      t.string    :reference
      t.text      :cancelled_comment 
      t.datetime  :cancelled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_requests
  end
end
