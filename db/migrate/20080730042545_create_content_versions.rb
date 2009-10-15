class CreateContentVersions < ActiveRecord::Migration
  def self.up
    create_table :content_versions do |t|
      t.references :menu, :content, :contributor
      t.string  :title, :description
      t.text    :text
      
      t.datetime :versioned_at
    end
  end

  def self.down
    drop_table :content_versions
  end
end
