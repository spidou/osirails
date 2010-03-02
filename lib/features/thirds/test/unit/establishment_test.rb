require 'test/test_helper'

class EstablishmentTest < Test::Unit::TestCase
  should_belong_to :customer
  should_belong_to :establishment_type
  
  context "An empty establishment" do
    setup do
      @establishment = Establishment.new
      @establishment.valid?
    end
    
    [ :name, :address, :establishment_type ].each do |attribute|
      should "require presence of #{attribute}" do
        assert @establishment.errors.invalid?(attribute)
      end
    end
  end
  
  context "A complete establishment" do
    setup do
      @establishment = Establishment.new(:name                  => "Name",
                                         :establishment_type_id => establishment_types(:store).id)
      @establishment.build_address(:street_name   => "Street Name",
                                   :zip_code      => "12345",
                                   :city_name     => "City",
                                   :country_name  => "Country")
      @establishment.valid?
    end
    
    [ :name, :address, :establishment_type ].each do |attribute|
      should "valid presence of #{attribute}" do
        assert !@establishment.errors.invalid?(attribute)
      end
    end
    
    should "be saved successfully" do
      assert @establishment.save!
    end
  end

#  # TODO test save address in has_address plugin
#  def test_save_address
#    @establishment.build_address(:street_name   => "1 rue des rosiers",
#                                 :country_name  => "Réunion",
#                                 :city_name     => "Saint-Denis",
#                                 :zip_code      => "97400")
#    @establishment.save!
#    assert @establishment.reload.address, "This Establishment should have an address"
#  end
end
