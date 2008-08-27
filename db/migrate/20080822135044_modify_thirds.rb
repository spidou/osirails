class ModifyThirds < ActiveRecord::Migration
  def self.up
    remove_column :thirds, :banking_informations
    remove_column :thirds, :legal_form
    add_column :thirds, :legal_form_id, :integer
    add_column :thirds, :iban_id, :integer
    add_column :thirds, :payment_method_id, :integer
    add_column :thirds, :payment_time_limit_id, :integer
  end

  def self.down
    remove_column :thirds, :legal_form_id
    remove_column :thirds, :iban_id
    remove_column :thirds, :payment_method_id
    remove_column :thirds, :payment_time_limit_id
    add_column :thirds, :banking_informations, :string
    add_column :thirds, :legal_form, :string
  end
end

