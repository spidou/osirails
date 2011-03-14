# This module is inspired by 'rails/actionpack/lib/action_controller/helpers.rb'
# it aggregates query's modules with helper's modules
#
module ActionController
  module Queries
    
    def self.included(base)
#      # Initialize the base module to aggregate its helpers.
#      base.class_inheritable_accessor :master_helper_module
#      base.master_helper_module = Module.new
#      
      # Extend base with class methods to declare helpers.
      base.extend(ClassMethods)

      base.class_eval do
        # Wrap inherited to create a new master helper module for subclasses.
        class << self
          alias_method_chain :inherited, :query
        end
      end
    end
    
    module ClassMethods
      
      def query(*args)
        args.flatten.each do |arg|
          case arg
            when Module
              add_template_helper(arg)
            when :all
              HasSearchIndex::MODELS.map(&:tableize).each do |m|  # try to include all queries_hepers
                begin query(m)
                rescue LoadError
                  next
                end
              end
            when String, Symbol
              file_name  = arg.to_s.underscore + '_query'
              class_name = file_name.camelize

              begin
                require_dependency(file_name)
              rescue LoadError => load_error
                requiree = / -- (.*?)(\.rb)?$/.match(load_error.message).to_a[1]
                if requiree == file_name
                  msg = "Missing helper file queries/#{file_name}.rb"
                  raise LoadError.new(msg).copy_blame!(load_error)
                else
                  raise
                end
              end

              add_template_helper(class_name.constantize)
            else
              raise ArgumentError, "query expects String, Symbol, or Module argument (was: #{args.inspect})"
          end
        end
      end
      
      private
      
        def inherited_with_query(child)
          inherited_without_query(child)
          
          begin
#            child.master_helper_module = Module.new
#            child.master_helper_module.__send__ :include, master_helper_module
            child.__send__ :default_query_module!
          rescue MissingSourceFile => e
            raise unless e.is_missing?("queries/#{child.controller_path}_query")
          end
        end
        
        def default_query_module!
          unless name.blank? || name == "ProductsCatalogController"
            module_name = name.sub(/Controller$|$/, 'Query')
            module_path = module_name.split('::').map { |m| m.underscore }.join('/')
            require_dependency(module_path)
            query(module_name.constantize)
          end
        rescue MissingSourceFile => e
          raise unless e.is_missing? module_path
        rescue NameError => e
          raise unless e.missing_name? module_name
        end
      
    end
    
  end
end

# Set it all up.
if Object.const_defined?("ActionController")
  ActionController::Base.send(:include, ActionController::Queries)
end
