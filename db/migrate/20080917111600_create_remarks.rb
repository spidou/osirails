class CreateRemarks < ActiveRecord::Migration
  def self.up
    create_table :remarks do |t|
      t.references :has_remark, :polymorphic => true
      t.references :user
      t.text :text
      
      t.timestamps
    end
  end

  def self.down
    drop_table :remarks
  end
end
