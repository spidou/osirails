require File.dirname(__FILE__) + '/../thirds_test'

class HeadOfficeTest < ActiveSupport::TestCase
  #FIXME this assert issues the following error :
  #      test: HeadOffice should journalize as expected.
  #       <nil> expected for HeadOffice.journal_identifier_method but was
  #       <:establishment_type_and_name>
  #      
  #      it seems to due to head_office inherit to establishment, and establishment do have a journal_identifier_method at 'establishment_type_and_name'
  #      we have to find why this attribute is getting from the inherited class
  should_journalize :attributes    => [ :name, :establishment_type_id, :activity_sector_reference_id, :siret_number, :activated, :hidden ],
                    :subresources  => [ :address, :phone, :fax, :contacts, :documents ],
                    :attachments   => :logo
end
