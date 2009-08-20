class DeleteColumnRetrievalIntoLeaves < ActiveRecord::Migration
  def self.up
    remove_column :leaves, :retrieval
  end

  def self.down
    add_column :leaves, :retrieval, :float
  end
end
