module ValidatesPersistenceOf
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    def validates_persistence_of(*attr_names)
      options = attr_names.last.is_a?(Hash) ? attr_names.pop : {}
      
      validates_each(attr_names, options) do |record, attr_name, value|
        next if record.new_record?
        has_changed = record.changed.include?(attr_name.to_s) || ( record.send(attr_name).respond_to?(:changed?) && record.send(attr_name).send(:changed?) ) ||
                                                                 ( record.send(attr_name).instance_of?(Array) && ( !record.send(attr_name).select{|r|r.respond_to?(:changed?) && r.changed?}.empty? ||
                                                                                                                    record.send(attr_name) != record.class.find(record.id).send(attr_name) ) )
        record.errors.add(attr_name, I18n.t('activerecord.errors.messages.has_changed')) if has_changed
      end
    end
    
  end
end

ActiveRecord::Base.send(:include, ValidatesPersistenceOf)
