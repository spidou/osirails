class JournalizationMigration < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.references :journalized, :polymorphic => true
      t.references :actor
      t.datetime   :created_at
    end
    
    create_table :journal_lines do |t|
      t.references :journal
      t.references :referenced_journal
      t.string     :property, :old_value, :new_value
      t.integer    :property_id
    end
    
    create_table :journal_identifiers do |t|
      t.references :journalized, :polymorphic => true
      t.references :journal
      t.string     :old_value, :new_value
    end
  end

  def self.down
    drop_table :journals
    drop_table :journal_lines
    drop_table :journal_identifiers
  end
end
