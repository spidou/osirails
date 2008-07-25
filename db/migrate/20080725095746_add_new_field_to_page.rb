class AddNewFieldToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :title, :string
    add_column :pages, :description, :string
    add_column :pages, :text, :text
    add_column :pages, :tags, :text
    add_column :pages, :author, :string
    add_column :pages, :contributors, :text
    
  end

  def self.down
  end
end
