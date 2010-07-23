class CreateMockupTypes < ActiveRecord::Migration
  def self.up
    create_table :mockup_types do |t|
      t.string  :name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :mockup_types
  end
end
