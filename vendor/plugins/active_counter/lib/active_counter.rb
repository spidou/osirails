module ActiveCounter
  ALL_COUNTERS = {}
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
    
    def update_all_counters
      ALL_COUNTERS.each do |model, counters|
        counters.keys.each do |counter_name|
          model.constantize.send("update_#{counter_name}_counter")
        end
      end
      true
    end
  end
  
  class ActiveCounterError < StandardError #:nodoc:
  end

  module ClassMethods
    def active_counter(options = {})
      include InstanceMethods
      
      options.symbolize_keys!
      
      model = options[:model] || self.name
      
      # counters validations
      if counters = options[:counters]
        raise ActiveCounterError, "You cannot define counters for another model" if options[:model]
        raise ActiveCounterError, ":counters expected to be a Hash, but was #{counters.class}:#{counters.inspect}" unless counters.is_a?(Hash)
        counters.each do |k, v|
          raise ActiveCounterError, ":counters types must be in #{Counter::ACCEPTED_TYPES.inspect}, but :#{k} got #{v.to_s.inspect}" unless Counter::ACCEPTED_TYPES.include?(v.to_s)
        end
      end
      
      # callbacks validations
      if callbacks = options[:callbacks]
        raise ActiveCounterError, ":callbacks expected to be a Hash, but was #{callbacks.class}:#{callbacks.inspect}" unless callbacks.is_a?(Hash)
        callbacks.each do |counter_name, cbs|
          raise ActiveCounterError, ":callbacks values must be either symbol, string or array, but :#{counter_name} got #{cbs.class}:#{cbs.inspect}" unless cbs.is_a?(String) or cbs.is_a?(Symbol) or cbs.is_a?(Array)
          cbs = [cbs] unless cbs.is_a?(Array)
          cbs.each do |cb|
            raise ActiveCounterError, ":callbacks values must be in #{ActiveRecord::Callbacks::CALLBACKS.inspect}, but :#{counter_name} got #{cb.to_s.inspect}" unless ActiveRecord::Callbacks::CALLBACKS.include?(cb.to_s)
          end
        end
      end
      
      write_inheritable_attribute(:active_counter_definitions, {}) if active_counter_definitions.nil?
      active_counter_definitions[model] = (active_counter_definitions[model] || {}).merge(options)
      
      # define counters
      if counters
        ActiveCounter::ALL_COUNTERS[model] = (ActiveCounter::ALL_COUNTERS[model] || {}).merge(counters)
        
        counters.each do |counter_name, type|
          counter_method_name = "#{counter_name}_counter"
          update_counter_method_name = "update_#{counter_method_name}"
          
          class_eval <<-EOL
            def self.#{counter_method_name}
              if counter = Counter.find_by_model_and_key("#{model}", "#{counter_method_name}")
                case counter.cast_type
                when "integer"
                  counter.value.to_i
                else
                  counter.value
                end
              else
                #TODO log error "Unable to find an ActiveCounter for model #{model} with key #{counter_method_name}"
                0
              end
            end
            
            def self.get_#{counter_method_name}; end
            
            def self.#{update_counter_method_name}
              counter = Counter.find_by_model_and_key("#{model}", "#{counter_method_name}") || Counter.create!(:model => "#{model}", :key => "#{counter_method_name}", :cast_type => "#{type.to_s}")
              if value = get_#{counter_method_name}
                counter.update_attribute(:value, value)
              end
            end
            
            def #{update_counter_method_name}
              self.class.#{update_counter_method_name}
            end
          EOL
        end
      end
      
      # define callbacks
      if callbacks
        callbacks.each do |counter_name, cbs|
          counter_method_name = "#{counter_name}_counter"
          
          return_counter_method_name = options[:model] ? "#{options[:model].underscore}_" : ""
          return_counter_method_name << counter_method_name
          
          update_counter_method_name = "update_#{return_counter_method_name}"
          
          if options[:model]
            class_eval <<-EOL
              def #{return_counter_method_name}
                #{options[:model]}.#{counter_method_name}
              end
              
              def #{update_counter_method_name}
                #{options[:model]}.update_#{counter_method_name}
              end
            EOL
          end
          
          cbs = [cbs] unless cbs.is_a?(Array)
          cbs.each do |cb|
            class_eval <<-EOL
              #{cb.to_s} :#{update_counter_method_name}
            EOL
          end
        end
      end
    end
    
    # Returns the active_counter definitions defined by each call to
    # active_counter.
    def active_counter_definitions
      read_inheritable_attribute(:active_counter_definitions)
    end
  end

  module InstanceMethods #:nodoc:
  end

end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, ActiveCounter)
end
