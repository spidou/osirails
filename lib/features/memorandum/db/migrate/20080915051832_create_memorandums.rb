class CreateMemorandums < ActiveRecord::Migration
  def self.up
    create_table :memorandums do |t|
      t.references :user
      t.string    :title, :subject, :signature
      t.text      :text
      t.datetime  :published_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :memorandums
  end
end
