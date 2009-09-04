class Document < ActiveRecord::Base
  # has_permissions :as_instance
  
  ## Plugins
  acts_as_taggable
  #acts_as_versioned
  
  ## Relationship
  belongs_to :has_document, :polymorphic => true
  belongs_to :document_type
  
  ## Validates
  validates_presence_of :name, :document_type_id
  
  # define if the object should be destroyed (after clicking on the remove button via the web site) # see for example the /customers/1/edit
  attr_accessor :should_destroy
  
  # define if the object should be updated 
  # should_update = 1 if the form is visible # see for example the /customers/1/edit
  # should_update = 0 if the form is hidden (after clicking on the cancel button via the web site) # see for example the /customers/1/edit
  attr_accessor :should_update
  
  cattr_accessor :documents_owners
  @@documents_owners = []
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
  @@form_labels[:description] = "Description :"
  @@form_labels[:document_type] = "Type de document :"
  @@form_labels[:tag_list] = "Mots-clés :"
  @@form_labels[:attachment] = "Fichier :"
  
  has_attached_file :attachment, 
                    :styles => { :medium => "500x500>",
                                 :thumb => "100x100#" },
                    :path => ":rails_root/assets/:class/:owner_class/:owner_id/:id/:style.:extension",
                    :url => "/attachments/:id/:style",
                    :default_url => "#{$CURRENT_THEME_PATH}/images/documents/missings/:mimetype_:style.png"
  
  validates_attachment_presence :attachment
  
  attr_protected :attachment_file_name, :attachment_content_type, :attachment_file_size
  
  cattr_accessor :forbidden_document_image_path
  @@forbidden_document_image_path = "public/#{$CURRENT_THEME_PATH}/images/documents/forbidden.png"
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def should_update?
    should_update.to_i == 1
  end
  
end
