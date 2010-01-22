class CreateAdjustments < ActiveRecord::Migration
  def self.up
    create_table :adjustments do |t|
      t.references :due_date
      t.float   :amount
      t.text    :comment
      t.string  :attachment_file_name, :attachment_content_type
      t.integer :attachment_file_size
      
      t.timestamps
    end
  end

  def self.down
    drop_table :adjustments
  end
end
