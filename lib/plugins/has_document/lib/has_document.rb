module HasDocument
  
  module ClassMethods
    
    def has_document options = {}
      include InstanceMethods
      
      has_many :documents, :as => :has_document
      
      write_inheritable_attribute(:document_definitions, {}) if document_definitions.nil?
    end
    def validates_document_presence

    end

    def validates_document_number

    end

    # Returns the document definitions defined by each call to
    # has_document.
    def attachment_definitions
      read_inheritable_attribute(:document_definitions)
    end
    
  end
  
  module InstanceMethods #:nodoc:
    
  end
  
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasDocument)
end