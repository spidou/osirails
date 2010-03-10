require 'test/test_helper'

class SubcontractorRequestTest < ActiveSupport::TestCase
  
  #TODO test has_permissions
  #TODO test has_documents
  
  should_belong_to :survey_step, :subcontractor
  
  should_have_attached_file :attachment
  
  should_validate_presence_of :job_needed
  should_validate_presence_of :subcontractor, :with_foreign_key => :default
  
  should_validate_numericality_of :price
  
  should_validate_attachment_presence :attachment
  should_validate_attachment_size :attachment, :less_than => 5.megabytes
  
  #FIXME this shoulda macro doesn't work. we have to find a solution
  # Here is the error thrown when I run tests : osirails/vendor/plugins/paperclip/shoulda_macros/paperclip.rb:41:in `should_validate_attachment_content_type': undefined method `allows' for #<Paperclip::Shoulda::Matchers::ValidateAttachmentPresenceMatcher:0xb61e6fd4> (NoMethodError)
  #should_validate_attachment_content_type :attachment, :valid   => [ 'application/pdf', 'application/x-pdf' ],
  #                                                     :invalid => [ 'image/jpg', 'image/png' ]
  
  #TODO validates_persistence_of :survey_step_id, :subcontractor_id
  #TODO validates_persistence_of :attachment, :if => :attachment
  
end
