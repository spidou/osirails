class CreateDunningMethods < ActiveRecord::Migration
  def self.up
    create_table :dunning_sending_methods do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :dunning_methods
  end
end
