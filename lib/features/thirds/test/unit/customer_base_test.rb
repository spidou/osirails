module CustomerBaseTest
  
  class << self
    def included base
      base.class_eval do
        
        should_belong_to :creator
        should_have_one :head_office
        should_have_many :establishments
        should_validate_presence_of :head_office
        
        context 'with required attributes' do
          setup do
            @customer.legal_form_id = create_legal_form.id
          end
          
          context 'and with a head_office and an etablishment' do
            setup do
              siret = rand(99999999999999).to_s.rjust(14, "0")
              @head_office = @customer.build_head_office( :name                   => "Customer Head Office",
                                                          :establishment_type_id  => establishment_types(:store).id,
                                                          :siret_number           => siret,
                                                          :activated              => true)
              @head_office.build_address(:street_name  => "Street Name",
                                         :country_name => "Country",
                                         :city_name    => "City",
                                         :zip_code     => "01234" )
              flunk 'Failed to build head_office' unless @customer.head_office
              
              
              siret2 = rand(99999999999999).to_s.rjust(14, "0")
              establishment = @customer.establishments.build( :name                   => "Customer Establishment",
                                                              :establishment_type_id  => establishment_types(:store).id,
                                                              :siret_number           => siret2,
                                                              :activated              => true)
              establishment.build_address( :street_name  => "Doe Street",
                                           :country_name => "Country",
                                           :city_name    => "City",
                                           :zip_code     => "01234" )
              flunk 'Failed to build establishments' unless @customer.establishments.any?
            end
            
            should 'have head_office in head_office_and_establishments' do
              assert @customer.head_office_and_establishments.detect{ |establishment| establishment == @customer.head_office }
            end
            
            context 'associated to a contact' do
              setup do
                @customer.establishments.first.contacts.build(:first_name => 'Jane',
                                                              :last_name  => 'Doe',
                                                              :job        => 'Commercial',
                                                              :email      => 'jane@doe.com',
                                                              :gender     => 'female')
              end
              
              should 'have a contact itself' do
                assert @customer.contacts.any?
              end
            end
            
            context 'then saved' do
              setup do
                flunk 'head_office should NOT have an ID before to be saved' unless @customer.head_office.id.nil?
                flunk 'etablishment should NOT have an ID before to be saved' unless @customer.establishments.first.id.nil?
                @customer.save!
              end
              
              should 'save the head_office too' do
                assert_not_nil @customer.head_office.id
              end
              
              should 'save the the etablishment too' do
                assert_not_nil @customer.establishments.first.id
              end
            end
          end
          
          context 'which is taking an etablishment and a head_office' do
            setup do
              flunk 'Should NOT have an etablishment' unless @customer.establishments.size == 0
              flunk 'Should NOT have a head_office' unless @customer.head_office.nil?
              @establishment_type = EstablishmentType.new(:name => 'Type')
              @establishment_type.save!
              
              @head_office = HeadOffice.new( {:name     => "Headquarter",
                                              :address  => create_address("Sainte Marie"),
                                              :type     => 'Type'})
              @head_office.establishment_type_id = @establishment_type.id
              @head_office.save!
              
              @establishment = Establishment.new(:address => create_address("Saint Denis"))
              @establishment.establishment_type_id = @establishment_type.id
              @establishment.save!
              
              @customer.head_office_attributes=([@head_office.attributes])
              @customer.head_office.address = @head_office.address
              @customer.establishment_attributes=([@establishment.attributes])
              @customer.establishments.first.address = @establishment.address
              @customer.save!
            end
            
            should 'have an establishment' do
              assert_equal 1, @customer.establishments.size
            end
            
            should 'have a head_office' do
              assert_not_nil @customer.head_office
            end
            
            context 'and which the etablishment is set to should_destroy' do
              setup do
                flunk 'Customer should have an establishment' unless @customer.establishments.size == 1
                @customer.establishments.first.should_destroy = 1
                @customer.save!
                @customer.reload
              end
              
              should 'NOT have establishment anymore' do
                assert @customer.establishments.empty?
              end
            end
          end
          
        end
          
      end
    end
  end
  
end
