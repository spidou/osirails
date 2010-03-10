class CreatePremia < ActiveRecord::Migration
  def self.up
    create_table :premia do |t|     
      t.references :employee
      t.date    :date
      t.decimal :amount, :precision => 65, :scale => 20
      t.text    :remark
      
      t.timestamps
    end
  end

  def self.down
    drop_table :premia
  end
end
