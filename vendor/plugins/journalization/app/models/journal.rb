class Journal < ActiveRecord::Base
  belongs_to :journalized, :polymorphic => true

  has_many   :journal_lines, :order => "property"
  has_one    :referenced_journal_line, :class_name => "JournalLine", :foreign_key => "referenced_journal_id"
  has_one    :journal_identifier
  
  def self.find_for(journalized_type, journalized_id)
    begin
      journalized = journalized_type.constantize.find(journalized_id)
    rescue
      journalized = nil
    end
    
    if journalized && journalized.respond_to?(:journals)
      return journalized.journals
    else
      return self.all.select {|i| i.journalized_type == journalized_type && i.journalized_id == journalized_id}
    end
  end
end
