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
    
    def has_documents options = {}
      include InstanceMethods
      
      has_many :documents, :as => :has_document
    end
    
    def validates_documents_presence
    end

    def validates_documents_number options = {}
    end
    
  end
  
  module InstanceMethods #:nodoc:
    
    def test
      "just a test!"
    end
    
  end
  
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasDocuments)
end