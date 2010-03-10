class CreateMemorandumsServices < ActiveRecord::Migration
  def self.up
    create_table :memorandums_services do |t|
      t.references :service, :memorandum
      t.boolean :recursive, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :memorandums_services
  end
end
