class RenameAuthorInContents < ActiveRecord::Migration
  def self.up
    remove_column :contents, :author
    add_column :contents, :author_id, :integer
  end

  def self.down    
    remove_column :contents, :author_id
    add_column :contents, :author, :string
  end
end
