class Test::Unit::TestCase
  
  def create_default_customer
    customer = thirds(:first_customer)
    customer.contacts << contacts(:pierre_paul_jacques)
    customer.build_bill_to_address( :street_name  => "Street Name",
                                    :country_name => "Country",
                                    :city_name    => "City",
                                    :zip_code     => "01234" )
    flunk "customer should be save > #{customer.errors.inspect}" unless customer.save!
    return customer
  end
  
end
