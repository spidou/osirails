require File.dirname(__FILE__) + '/unit/siret_number_test'

class Test::Unit::TestCase
  
  def get_customer(factorised = true)
    if factorised == true
      customer = thirds(:factorised_customer)
    else
      customer = thirds(:first_customer)
    end
    
    head_office = build_head_office_for(customer)
    
    if customer.establishments.empty?
      establishment = build_establishment_for(customer)
      establishment.contacts = [ contacts(:pierre_paul_jacques), contacts(:jean_dupond) ]
    end
    
    customer.build_bill_to_address( :street_name  => "Street Name",
                                    :country_name => "Country",
                                    :city_name    => "City",
                                    :zip_code     => "01234" ) unless customer.bill_to_address
    customer.save!
    flunk "customer should be saved" if customer.new_record?
    return customer
  end
  
  def build_establishment_for(customer)
    siret = rand(99999999999999).to_s.rjust(14, "0")
    establishment = customer.establishments.build(:name                   => "Customer Establishment",
                                                  :establishment_type_id  => EstablishmentType.first.id,
                                                  :siret_number           => siret,
                                                  :activated              => true)
    establishment.build_address( :street_name  => "Street Name",
                                 :country_name => "Country",
                                 :city_name    => "City",
                                 :zip_code     => "01234" )
    return establishment
  end
  
  def build_head_office_for(customer)
    siret = rand(99999999999999).to_s.rjust(14, "0") 
    establishment = customer.build_head_office( :name                   => "Customer Head Office",
                                                :establishment_type_id  => EstablishmentType.first.id,
                                                :siret_number           => siret,
                                                :activated              => true)
    establishment.build_address( :street_name  => "Street Name",
                                 :country_name => "Country",
                                 :city_name    => "City",
                                 :zip_code     => "01234" )
    return establishment
  end
  
end
