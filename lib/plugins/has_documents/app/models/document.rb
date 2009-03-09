class Document < ActiveRecord::Base
  has_permissions
  
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
  
#  @@models = []
#  @image_mime_types = ["image/jpeg","image/png"]
  
#  # Add the model name into models array
#  def self.add_model(model)
#    @@models << model
#  end
#  
#  ## Return model array that can get document
#  def self.models
#    @@models
#  end
#  
#  def self.add_image_mime_type(image_mime_type)
#    @image_mime_types << image_mime_type
#  end
#  
#  def self.image_mime_types
#    @image_mime_types
#  end
#  
#  def press_proof_valid?
#    Document.image_mime_types.include?(self.mime_type)
#  end
#  
#  def self.can_have_document(model)
#    @models.include?(model)
#  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def should_update?
    should_update.to_i == 1
  end
  
#  def mime_type 
#    File.mime_type?("#{self.path}#{self.id}.#{self.extension}")
#  end
  
#  # This method permit to attribute a value to versioned_at
#  def updated_at=(value)
#    self.versioned_at = value
#  end
#  
#  ## Create thumbnails
#  def create_thumbnails
#    require 'RMagick'
#    if Document.image_mime_types.include?(self.mime_type)
#      path = "documents/#{self.owner_class.downcase}/#{self.file_type.id}/"
#      thumbnail = Magick::Image.read("#{path}#{self.id}.#{self.extension}").first
#      thumbnail.crop_resized!(75, 75, Magick::NorthGravity)
#      thumbnail.write("#{path}/#{self.id}_75_75.#{self.extension}")
#    else 
#      return false
#    end
#  end
#  
#  ## Create preview format
#  def create_preview_format
#    require 'RMagick'
#    if Document.image_mime_types.include?(self.mime_type)
#      path = "documents/#{self.owner_class.downcase}/#{self.file_type.id}/"
#      image = Magick::Image.read("#{path}#{self.id}.#{self.extension}").first
#      image.resize_to_fit!(770, 450)
#      image.write("#{path}/#{self.id}_770_450.#{self.extension}")
#    else
#      return false
#    end
#  end
#  
#  def convert_to_png
#    require 'RMagick'
#    if Document.image_mime_types.include?(self.mime_type)
#      path = "documents/#{self.owner_class.downcase}/#{self.file_type.id}/"
#      image = Magick::ImageList.new("#{path}#{self.id}.#{self.extension}")
#      image.resize_to_fit!(550, 700)
#      image.write("#{path}#{self.id}.png")
#    end
#  end
#  
#  ## Return address file
#  def get_png
#    path = "documents/" + self.path +  self.id.to_s + ".png"
#    File.exist?(path) ? File.join(RAILS_ROOT, path) : false
#  end
#  
#  ## Return owner class
#  def owner_class
#    self.has_document.class.name.downcase
#  end
#  
#  ## Return file of document
#  def get_file
#    if self.is_new
#      return file
#    else
#      path = "documents/" + self.path +  self.id.to_s + "." + self.extension
#      return File.open((path), "r")
#    end
#    return false
#  end
#  
#  ## Return document path
#  def path
#    return self.owner_class + "/" + self.file_type_id.to_s + "/"
#  end
#  
#  ## Override new method
#  def self.new(document = nil)
#    unless document.nil?
#      unless document[:owner].nil?
#    
#        ## affect document_name with original document name if associated textfield is undefined 
#        document[:name].blank? ? document_name = ((a = document[:datafile].original_filename.split("."); a.pop; a.to_s) unless document[:datafile].blank?) : document_name = document[:name]
#    
#        @document =super(
#          :name => document_name , 
#          :description => document[:description],
#          :extension => (FileManager.real_extension(document[:datafile]) unless document[:datafile].nil?))
#        @document.file_type = FileType.find(document[:file_type_id]) unless document[:file_type_id].nil?
#        @document.owner = document[:owner]
#        @document.file = document[:datafile] unless document[:datafile].blank?
#        @document.is_new = true
#        return @document
#      else
#        raise "Document require owner attribute. example : Document.new(:owner => Employee.last)"
#      end
#    else
#      return false
#    end
#  end
#  
#  def self.create_all(documents, owner)
#    if documents.keys.size.to_i > 0
#      document_objects = []
#      documents.keys.size.to_i.times do |i|
#        unless documents["#{i+1}"][:valid] == "false"
#          documents["#{i+1}"][:owner] = owner
#          document_objects << Document.new(documents["#{i+1}"])
#        end
#      end
#      return document_objects
#    end   
#  end
#  
#  ## Override update_attributes method
#  def update_attributes(document = nil)
#    unless document.nil?
#      unless document[:upload].nil?
#        unless document[:upload][:datafile].blank?
#          self.file = document[:upload][:datafile]
#          self.create_preview_format
#          if self.valid?
#            ## Store tags list
#            tag_list = document.delete("tag_list").split(",")  unless document[:tag_list].nil?
#            
#            ## Creation of document_version          
#            path = "documents/" + self.path + self.id.to_s + "/"
#            file_response = FileManager.upload_file(:file => {:datafile =>document[:upload][:datafile]}, :name => (self.document_versions.size + 1).to_s, 
#              :directory => path, :file_type_id => self.file_type.id)
#            if file_response == true
#              @document_version = DocumentVersion.create(:name => (document[:name].blank? ? document[:upload][:datafile].original_filename : document[:name]), :description => self.description, :versioned_at => self.updated_at)      
#              ## Add tag_list for document
#              self.tag_list = tag_list
#              
#              self.document_versions << @document_version
#              
#              @document_version.create_thumbnails
#              @document_version.create_preview_format
#              document.delete("name") if document[:name].blank?
#              document.delete(:upload)
#              #              raise document.inspect
#              super(document)
#              return self
#            end
#          else
#            return self
#          end
#        else
#          self.errors.add("Le fichier", "n'a pas été trouvé")
#          return self
#        end        
#      else
#        return false
#      end
#    else
#      super ## document.nil?
#    end
#  end
#  
#  ## Override valid? method
#  def valid?
#    unless self.file_type.nil?
#      unless self.file
#        self.errors.add("Le fichier", "n'a pas été trouvé")
#        return false
#      end
#      
#      if FileManager.valid_mime_type?(self.file, self.file_type.id)
#        return super     
#      else
#        ## If document mime_type is invalid for his file_type
#        self.errors.add("Le type", "du fichier ne correspond pas avec son extension")
#        return false
#      end
#    else
#      ## If his file_type is undefine, it impossible to test if it's a valid document
#      return false
#    end
#    return false
#  end
#  
#  ## Override save method
#  def save()
#    if self.is_new == true
#      if self.owner.valid?
#        
#        unless self.file.nil?
#          unless self.file.blank?
#            if self.valid?
#              super
#              path = "documents/" + self.owner.class.name.downcase + "/" + self.file_type.id.to_s.downcase + "/"
#              file_response = FileManager.upload_file(:file => {:datafile => self.file}, :name => self.id.to_s, 
#                :directory => path, :file_type_id => self.file_type.id)
#              ## If file succefuly create
#              if file_response == true
#                ## Add tag_list for document
#                unless self.tag_list.nil?
#                  self.tag_list.each {|tag| self.tag_list << tag.strip} 
#                  #FIXME Verify if it's necessary
#                  self.tag_list.uniq!
#                end
#                self.is_new = false
#                return true            
#              else
#                self.destroy
#                return file_response
#              end
#            end
#          else
#            return false
#          end
#        else
#          return false ## file.nil?
#        end
#      else
#        return false ## owner.valid?
#      end
#    else
#      super
#    end
#  end
  
end
