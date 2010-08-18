require File.dirname(__FILE__) + '/../test_helper.rb'

class JournalTest < ActiveRecordTestCase
  should_belong_to :journalized
  
  should_have_many :journal_lines
  
  should_have_one :referenced_journal_line, :journal_identifier
end

