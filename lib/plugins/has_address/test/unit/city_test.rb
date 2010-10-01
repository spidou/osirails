require File.dirname(__FILE__) + '/../has_address_test'

class CityTest < ActiveSupport::TestCase
  should_belong_to :country, :region
  
  should_validate_presence_of :name, :zip_code, :country_id
  
  context "A new city with @france as country" do
    setup do
      @france = Country.create(:name => "France", :code => "FRA")
      @spain  = Country.create(:name => "Spain", :code => "ESP")
      
      flunk "@france should be created to perform the next tests" if @france.new_record?
      flunk "@spain should be created to perform the next tests"  if @spain.new_record?
      
      @city = City.create(:name => "Uni City", :zip_code => "AH1N1", :country_id => @france.id)
      
      flunk "@city should be created to perform the next tests" if @city.new_record?
    end
    
    context "and @cataluna as region whom country is @spain" do
      setup do
        @cataluna = Region.create(:name => "Cataluña", :country_id => @spain.id)
        flunk "@cataluna should be created to perform the next tests" if @cataluna.new_record?
        
        @city.region = @cataluna
        @city.valid?
      end
      
      should "have an invalid region_id" do
        assert @city.errors.invalid?(:region_id)
      end
    end
    
    context "and @aquitaine as region whom country is @france" do
      setup do
        @aquitaine = Region.create(:name => "Aquitaine", :country_id => @france.id)
        flunk "@aquitaine should be created to perform the next tests" if @aquitaine.new_record?
        
        @city.region = @aquitaine
      end
      
      should "be valid" do
        assert @city.valid?
      end
    end
  end
end
