require File.dirname(__FILE__) + '/../test_helper.rb'

class JournalIdentifierTest < ActiveRecordTestCase
  should_belong_to :journal, :journalized
  
  should_validate_presence_of :journal
end
