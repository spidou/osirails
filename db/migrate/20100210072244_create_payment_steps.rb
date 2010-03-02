class CreatePaymentSteps < ActiveRecord::Migration
  def self.up
    create_table :payment_steps do |t|
      t.references :invoicing_step
      t.string    :status
      t.datetime  :started_at
      t.datetime  :finished_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :payment_steps
  end
end
