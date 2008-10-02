class CreateMimeTypes < ActiveRecord::Migration
  def self.up
    create_table :mime_types do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :mime_types
  end
end
