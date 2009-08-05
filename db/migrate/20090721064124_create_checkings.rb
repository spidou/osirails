class CreateCheckings < ActiveRecord::Migration
  def self.up
    create_table :checkings do |t|
      t.date :date
      t.integer :user_id
      t.integer :employee_id
      t.decimal :duration,  :precision => 10
      t.text :comment
      t.timestamps
    end
  end

  def self.down
  end
end
