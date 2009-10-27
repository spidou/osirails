class AddColumnsOnQuotes < ActiveRecord::Migration
  def self.up
    add_column :quotes, :discount, :float, :default => 0.0
    add_column :quotes, :sales_terms, :text
  end

  def self.down
    remove_column :quotes, :discount
    remove_column :quotes, :sales_terms
  end
end
