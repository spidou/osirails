#  journalization  Copyright (C) 2010  Ronnie Heritiana RABENANDRASANA (http://github.com/rOnnie974)
#
#  Contributor: Mathieu FONTAINE aka spidou (http://github.com/spidou)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.

class JournalIdentifier< ActiveRecord::Base
  belongs_to :journal
  belongs_to :journalized, :polymorphic => true
  
  validates_presence_of :journal
  
  def self.find_for(journalized_type, journalized_id, datetime = Time.now)
    journalized = journalized_type.constantize.find(journalized_id) rescue nil
    
    if journalized && journalized.respond_to?(:journal_identifiers)
      journalized.journal_identifiers(:include => :journal, :order => 'journals.created_at', :conditions => [ "journals.created_at <= ?", datetime ])
    else
      self.all(:include => :journal, :conditions => [ "journal_identifiers.journalized_type = ? AND journal_identifiers.journalized_id = ? AND journals.created_at <= ?", journalized_type, journalized_id, datetime ], :order => "journals.created_at")
    end
  end
  
  def self.find_last_for(journalized_type, journalized_id, datetime = Time.now)
    self.find_for(journalized_type, journalized_id, datetime).last
  end
end
