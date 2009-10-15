class CreateInvoicingSteps < ActiveRecord::Migration
  def self.up
    create_table :invoicing_steps do |t|
      t.references :order
      t.string    :status
      t.datetime  :started_at, :finished_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invoicing_steps
  end
end
