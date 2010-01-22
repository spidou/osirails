class Test::Unit::TestCase
  
  def create_default_customer(factorised = true)
    if factorised == true
      customer = thirds(:factorised_customer)
    else
      customer = thirds(:first_customer)
    end
    
    establishment = build_establishment_for(customer)
    establishment.contacts = [ contacts(:pierre_paul_jacques), contacts(:jean_dupond) ]
    
    customer.build_bill_to_address( :street_name  => "Street Name",
                                    :country_name => "Country",
                                    :city_name    => "City",
                                    :zip_code     => "01234" )
    flunk "customer should be save > #{customer.errors.inspect} > #{customer.establishments.size} > #{customer.establishments.first.errors.inspect}" unless customer.save
    return customer
  end
  
  def build_establishment_for(customer)
    establishment = customer.establishments.build(:name                   => "Customer Establishment",
                                                  :establishment_type_id  => EstablishmentType.first.id,
                                                  :activated              => true)
    establishment.build_address( :street_name  => "Street Name",
                                 :country_name => "Country",
                                 :city_name    => "City",
                                 :zip_code     => "01234" )
    return establishment
  end
  
end
