class CreateMemorandums < ActiveRecord::Migration
  def self.up
    create_table :memorandums do |t|
      t.string :title, :subject, :signature
      t.integer :user_id
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :memorandums
  end
end
