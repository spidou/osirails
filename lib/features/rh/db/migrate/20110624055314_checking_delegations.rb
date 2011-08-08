class CheckingDelegations < ActiveRecord::Migration
  def self.up
    create_table :checking_delegations do |t|
      t.references :delegate , :employee
      t.timestamps
    end
  end

  def self.down
    drop_table :checking_delegations
  end
end
