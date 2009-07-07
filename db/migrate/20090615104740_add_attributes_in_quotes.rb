class AddAttributesInQuotes < ActiveRecord::Migration
  def self.up
    remove_column :quotes, :validated
    remove_column :quotes, :validity_date
    remove_column :quotes, :validated_at
    
    add_column :quotes, :status,                  :string
    add_column :quotes, :validity_delay_unit,     :string
    add_column :quotes, :validity_delay,          :integer
    add_column :quotes, :validated_on,            :date
    add_column :quotes, :invalidated_on,          :date
    add_column :quotes, :sended_on,               :date
    add_column :quotes, :send_quote_method_id,    :integer
    add_column :quotes, :signed_on,               :date
    add_column :quotes, :public_number,           :string
    add_column :quotes, :order_form_file_name,    :string
    add_column :quotes, :order_form_content_type, :string
    add_column :quotes, :order_form_file_size,    :integer
    add_column :quotes, :order_form_type_id,      :integer
    
    add_index :quotes, :public_number, :unique => true
  end

  def self.down
    add_column :quotes, :validated,     :boolean
    add_column :quotes, :validity_date, :date
    add_column :quotes, :validated_at,  :datetime
    
    remove_index :quotes, :public_number
    
    remove_column :quotes, :status
    remove_column :quotes, :validity_delay_unit
    remove_column :quotes, :validity_delay
    remove_column :quotes, :validated_on
    remove_column :quotes, :invalidated_on
    remove_column :quotes, :sended_on
    remove_column :quotes, :send_quote_method_id
    remove_column :quotes, :signed_on
    remove_column :quotes, :public_number
    remove_column :quotes, :order_form_file_name
    remove_column :quotes, :order_form_content_type
    remove_column :quotes, :order_form_file_size
    remove_column :quotes, :order_form_type_id
  end
end
