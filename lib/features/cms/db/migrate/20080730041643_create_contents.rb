class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.references :menu, :author
      t.string  :title, :description
      t.text    :text
      t.string  :contributors
      t.integer :lock_version, :default => 0, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contents
  end
end
