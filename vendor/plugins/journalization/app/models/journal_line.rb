class JournalLine < ActiveRecord::Base
  belongs_to :journal
  belongs_to :referenced_journal, :class_name => "Journal", :foreign_key => "referenced_journal_id"

  validates_presence_of :journal
end

