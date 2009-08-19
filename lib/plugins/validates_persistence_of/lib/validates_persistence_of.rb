module ValidatesPersistenceOf
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    def validates_persistence_of(*attr_names)
      configuration = { :message => ActiveRecord::Errors.default_error_messages[:has_changed] }
      configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
      
      validates_each(attr_names, configuration) do |record, attr_name, value|
        next if record.new_record?
        original_record = record.class.find(record.id)
        has_changed = original_record.send(attr_name) != value
        record.errors.add(attr_name, configuration[:message]) if has_changed
      end
    end
    
  end
end

ActiveRecord::Base.send(:include, ValidatesPersistenceOf)

module ActiveRecord
  class Errors
    @@default_error_messages.update( {
      :has_changed => "a été modifié"
    })
  end
end
