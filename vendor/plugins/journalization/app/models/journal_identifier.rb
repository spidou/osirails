class JournalIdentifier< ActiveRecord::Base
  belongs_to :journal
  belongs_to :journalized, :polymorphic => true

  validates_presence_of :journal
  
  def self.find_for(journalized_type, journalized_id, datetime = Time.now)
    begin
      journalized = journalized_type.constantize.find(journalized_id)
    rescue
      journalized = nil
    end
    
    if journalized && journalized.respond_to?(:journal_identifiers)
      return journalized.journal_identifiers.select {|i| i.journal.created_at <= datetime}.sort_by {|i| i.journal.created_at}
    else
      return self.all.select {|i| i.journalized_type == journalized_type && i.journalized_id == journalized_id && i.journal.created_at <= datetime}.sort_by {|i| i.journal.created_at}
    end
  end
  
  def self.find_last_for(journalized_type, journalized_id, datetime = Time.now)
    self.find_for(journalized_type, journalized_id, datetime).last
  end
end

