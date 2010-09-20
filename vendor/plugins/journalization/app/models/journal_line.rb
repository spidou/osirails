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

class JournalLine < ActiveRecord::Base
  belongs_to :journal
  belongs_to :referenced_journal, :class_name => "Journal", :foreign_key => "referenced_journal_id"

  validates_presence_of :journal
  
  def old_value
    cast(self[:old_value], self.property_type)
  end
  
  def new_value
    cast(self[:new_value], self.property_type)
  end
  
  def cast(value, type)
    return if value.blank?
    case type
      when "boolean"
        return (value == "true" ? true : false)
      when "integer"
        return value.to_i
      when "float"
        return value.to_f
      when "decimal"
        return value.to_d
      when "datetime"
        return value.to_datetime
      when "time"
        return value.to_time
      when "date"
        return value.to_date
      when "serialized_array"
        return YAML.load(value)
      else
        return value.to_s
    end
  end
end
