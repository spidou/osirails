class CreateRemarks < ActiveRecord::Migration
  def self.up
    create_table :remarks do |t|
      t.text :text
      t.references :user # Store id's user who have create remark
      t.references :has_remark, :polymorphic => true
      t.references :user
      
      t.timestamps
    end
  end

  def self.down
    drop_table :remarks
  end
end
