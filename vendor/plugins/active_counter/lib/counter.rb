module ActiveCounter
  class Counter < ActiveRecord::Base
    set_table_name :active_counters
    
    ACCEPTED_TYPES = %w( integer float )
    
    validates_presence_of :model, :key
    validates_uniqueness_of :key, :scope => :model
    validates_inclusion_of :cast_type, :in => ACCEPTED_TYPES
  end
end
