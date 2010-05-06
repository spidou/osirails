module SiretNumberTest
  # this module should be implemented into the calling classe's test suite
  #
  # ==== Example
  # into "supplier_test.rb"
  #
  #   context "A supplier" do
  #     setup do
  #       @siret_number_owner = Supplier.new
  #     end
  #     
  #     subject { @siret_number_owner }
  #    
  #     include SiretNumberTest
  #   end
  #
  class << self
    def included base
      base.class_eval do
        
        # subject{ @siret_number_owner } # don't uncomment this line ! if we set up subject here instead of in each caller class, it fail all other shoulda methods for the given class
        
        should_allow_values_for     :siret_number, nil, "", "123456789", "12345678901234"
        should_not_allow_values_for :siret_number, "1", "12345678", "1234567890", "123456789012345"
        
        should "respond_to formatted_siret_number" do
          assert @siret_number_owner.respond_to?(:formatted_siret_number)
        end
        
        should "have the 'siret_number' form_label" do
          assert_not_nil @siret_number_owner.class.form_labels[:siret_number]
        end
        
        
        context "with a 14 chars siret_number" do
          setup do
            @siret_number_owner.siret_number = "12345678901234"
          end
          
          should "have a well-formed stored siret_number" do
            assert_equal "12345678901234", @siret_number_owner.siret_number
          end
          
          should "have a well-formed formatted_siret_number" do
            assert_equal "123 456 789 01234", @siret_number_owner.formatted_siret_number
          end
          
          should "store a well-formed siret_number" do
            @siret_number_owner.siret_number = "12345678901234"
            assert_equal "12345678901234", @siret_number_owner.siret_number
          end
          
          should "store a well-formed siret_number even with spaces" do
            @siret_number_owner.siret_number = "123 456 789 01234"
            assert_equal "12345678901234", @siret_number_owner.siret_number
          end
          
          should "store a well-formed siret_number even with too many spaces" do
            @siret_number_owner.siret_number = "12 34 56 78 90 1234 "
            assert_equal "12345678901234", @siret_number_owner.siret_number
          end
        end
        
        context "with a 9 chars siret_number" do
          setup do
            @siret_number_owner.siret_number = "123456789"
          end
          
          should "have a well-formed stored siret_number" do
            assert_equal "123456789", @siret_number_owner.siret_number
          end
          
          should "have a well-formed formatted_siret_number" do
            assert_equal "123 456 789", @siret_number_owner.formatted_siret_number
          end
          
          should "store a well-formed siret_number" do
            @siret_number_owner.siret_number = "123456789"
            assert_equal "123456789", @siret_number_owner.siret_number
          end
          
          should "store a well-formed siret_number even with spaces" do
            @siret_number_owner.siret_number = "123 456 789"
            assert_equal "123456789", @siret_number_owner.siret_number
          end
          
          should "store a well-formed siret_number even with too many spaces" do
            @siret_number_owner.siret_number = "12 34 56 78 9 "
            assert_equal "123456789", @siret_number_owner.siret_number
          end
        end
        
      end
    end
  end
end
