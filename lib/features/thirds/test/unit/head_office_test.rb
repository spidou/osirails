require File.dirname(__FILE__) + '/../thirds_test'

class HeadOfficeTest < ActiveSupport::TestCase
  should_journalize :attributes         => [ :name, :establishment_type_id, :activity_sector_reference_id, :siret_number, :activated, :hidden ],
                    :subresources       => [ :address, :phone, :fax, :contacts, :documents ],
                    :attachments        => :logo,
                    :identifier_method  => :establishment_type_and_name
end
