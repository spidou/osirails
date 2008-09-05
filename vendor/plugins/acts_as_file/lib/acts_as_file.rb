require 'active_record'

module ActiveRecord
  module Acts #:nodoc:
    module File #:nodoc:

      def self.included(mod)
        mod.extend(ClassMethods)
      end
      
      # declare the class level helper methods which
      # will load the relevant instance methods
      # defined below when invoked
      module ClassMethods
        def acts_as_file
          # this is at the class level
          # add any class level manipulations you need here, like has_many, etc.
          extend ActiveRecord::Acts::File::SingletonMethods
          include ActiveRecord::Acts::File::InstanceMethods
          
          has_many :documents, :as => :has_document
          Document.add_model(self.name) unless Document.models.include?(self.name)
          
          unless DocumentPermission.find_all_by_document_owner(self.name).size == Role.find(:all).size
            Role.find(:all).each do |role|
              DocumentPermission.find_or_create_by_document_owner_and_role_id(self.name, role.id)
            end
          end
          
        end
      end

      # Adds SingletonMethods
      module SingletonMethods
       
      end

      # Adds instance methods.
      module InstanceMethods

      end

    end
  end
end
