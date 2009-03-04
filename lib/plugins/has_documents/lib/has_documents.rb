module HasDocuments
  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end
  
  module ClassMethods
    
    def has_documents *options
      include InstanceMethods
      
      cattr_accessor :available_document_types
      self.available_document_types = []
      
      options.each do |document_type|
        dt = DocumentType.find_or_create_by_name(document_type.to_s)
        self.available_document_types << dt
      end
      
      Document.documents_owners << self
      
      class_eval do
        has_many :documents, :as => :has_document
        
        def document_attributes=(document_attributes)
          document_attributes.each do |attributes|
            if attributes[:id].blank?
              if attributes[:attachment].kind_of?(String) and !attributes[:attachment].empty?
                raise "Attachment requires form with multipart support (call form_for or form_tag with option :html => { :multipart => true })"
              end
              documents.build(attributes)
            else
              document = documents.detect { |t| t.id == attributes[:id].to_i }
              document.attributes = attributes
            end
          end
        end
        
        after_update :save_documents
        
        def save_documents
          documents.each do |d|
            if d.should_destroy?
              d.destroy
            elsif d.should_update?
              d.save(false)
            end
          end
        end
      end
      
    end
    
    def validates_documents_presence
    end
    
    def validates_documents_number options = {}
    end
    
  end
  
  module InstanceMethods
    
    def build_document
      Document.new(:has_document_id => self.id, :has_document_type => self.class.name)
    end
    
  end
  
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasDocuments)
end
