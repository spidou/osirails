class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.references :creator
      t.string     :name, :page_name, :search_type, :quick_search_value
      t.text       :criteria, :columns, :order, :group
      t.boolean    :public_access, :default => false
      t.integer    :per_page
      
      t.timestamps
    end
  end

  def self.down
    drop_table :queries
  end
end
