module SupplierBaseTest
  
  class << self
    def included base
      base.class_eval do
        
        should_have_one :iban
        should_validate_uniqueness_of :siret_number
        
        context 'with required attributes and a built iban then saved' do
          setup do
            @supplier = create_supplier(@supplier)
          end
          
          should 'have saved the iban too' do
            assert_not_nil @supplier.iban.id
          end
        end
        
      end
    end
  end
  
end
