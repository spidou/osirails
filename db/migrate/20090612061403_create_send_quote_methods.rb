class CreateSendQuoteMethods < ActiveRecord::Migration
  def self.up
    create_table :send_quote_methods do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :send_quote_methods
  end
end
