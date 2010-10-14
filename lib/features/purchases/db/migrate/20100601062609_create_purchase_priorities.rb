class CreatePurchasePriorities < ActiveRecord::Migration
  def self.up
    create_table :purchase_priorities do |t|
      t.string      :name
      t.integer     :position
      t.boolean     :default

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_priorities
  end
end
