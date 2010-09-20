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

class JournalizationMigration < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.references :journalized, :polymorphic => true
      t.references :actor
      t.datetime   :created_at
    end
    
    create_table :journal_lines do |t|
      t.references :journal
      t.references :referenced_journal
      t.string     :property, :property_type, :old_value, :new_value
      t.integer    :property_id
    end
    
    create_table :journal_identifiers do |t|
      t.references :journalized, :polymorphic => true
      t.references :journal
      t.string     :old_value, :new_value
    end
  end

  def self.down
    drop_table :journals
    drop_table :journal_lines
    drop_table :journal_identifiers
  end
end
