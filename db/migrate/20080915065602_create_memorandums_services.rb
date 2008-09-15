class CreateMemorandumsServices < ActiveRecord::Migration
  def self.up
    create_table :memorandums_services do |t|
      t.integer :service_id, :memorandum_id
      t.boolean :recursive, :default => false

      t.timestamps
    end
  rename_column(:memorandums, :created_at, :published_at)
  end

  def self.down
    drop_table :memorandums_services
  end
end
