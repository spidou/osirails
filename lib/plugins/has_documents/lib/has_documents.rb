# load models, controllers and helpers
%w{ models controllers helpers }.each do |dir|
  path = File.join(File.dirname(__FILE__), '..', 'app', dir)
  $LOAD_PATH << path
  Dependencies.load_paths << path
  Dependencies.load_once_paths.delete(path) # in development mode, this permits to avoid restart the server after any modifications on these paths (to confirm)
end

# load views
ActionController::Base.append_view_path(File.join(File.dirname(__FILE__), '..', 'app', 'views'))

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
  
  module InstanceMethods #:nodoc:
    
    def build_document
      Document.new(:has_document_id => self.id, :has_document_type => self.class.name)
    end
    
  end
  
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasDocuments)
end