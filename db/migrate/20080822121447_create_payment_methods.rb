class CreatePaymentMethods < ActiveRecord::Migration
  def self.up
    create_table :payment_methods do |t|
      t.string :name

      t.timestamps
    end
    
    PaymentMethod.create :name => "Virement"
    PaymentMethod.create :name => "Chèque"
    PaymentMethod.create :name => "Espèce"
    PaymentMethod.create :name => "Lettre de change"
    PaymentMethod.create :name => "Billet à ordre"
        
  end

  def self.down
    drop_table :payment_methods
  end
end
