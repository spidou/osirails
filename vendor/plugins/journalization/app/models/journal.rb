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

class Journal < ActiveRecord::Base
  belongs_to :journalized, :polymorphic => true

  has_many   :journal_lines
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
