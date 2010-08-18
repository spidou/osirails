require File.dirname(__FILE__) + '/../test_helper.rb'

class JournalLineTest < ActiveRecordTestCase
  should_belong_to :journal, :referenced_journal
  
  should_validate_presence_of :journal
end
