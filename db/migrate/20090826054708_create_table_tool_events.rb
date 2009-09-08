class CreateTableToolEvents < ActiveRecord::Migration
  def self.up
    create_table :tool_events do |t|
      t.integer :status, :event_type
      t.date :start_date, :end_date
      t.text :comment
      t.string :name, :provider_society, :provider_actor
      t.references :tool, :internal_actor, :event

      t.timestamps
    end
  end

  def self.down
    drop_table :tool_events
  end
end
