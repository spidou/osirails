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

