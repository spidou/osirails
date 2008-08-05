class CreateOrganizationTypes < ActiveRecord::Migration
  def self.up
    create_table :establishment_types do |t|
      t.string :wording
      
      t.timestamps
    end
  end

  def self.down
    drop_table :establishment_types
  end
end
