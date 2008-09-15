class Document < ActiveRecord::Base
  
  acts_as_taggable
  
  include Permissible
  
  belongs_to :file_type
  has_many :document_versions
  belongs_to :has_document, :polymorphic => true
  
  validates_presence_of :name
  
  attr_accessor :owner
  attr_accessor  :tag_list
  attr_accessor :file 
  
  attr_accessor :models
  attr_accessor :image_extensions
  
  
  @image_extensions = ["jpg", "jpeg","png","gif"]
  @models = []
  
  # Add the model name into models array
  def self.add_model(model)
    @models << model
  end
  
  ## Return model array that can get document
  def self.models
    @models
  end
  
  def self.add_image_extension(image_extension)
    @image_extensions << image_extension
  end
  
  def self.image_extensions
    @image_extensions
  end
  
  def self.can_have_document(model)
    if @models.include?(model)
      true
    else
      false
    end
  end
  
  # This method permit to attribute a value to versioned_at
  def updated_at=(value)
    self.versioned_at = value
  end
  
  ## Return owner class
  def owner_class
    self.has_document.class.name.downcase
  end
  
  ## Create thumbnails
  def create_thumbnails
    require 'RMagick'
    if Document.image_extensions.include?(self.extension)
      path = "documents/#{self.owner_class.downcase}/#{self.file_type_id}/"
      thumbnail = Magick::Image.read("#{path}#{self.id}.#{self.extension}").first
      thumbnail.crop_resized!(75, 75, Magick::NorthGravity)
      thumbnail.write("#{path}/#{self.id}_75_75.#{self.extension}")
    end
  end
  
  ## Return document path
  def path
    self.owner_class + "/" + self.file_type_id.to_s + "/"
  end
  
  ## Override new methods
  def self.new(document = nil)
    
    unless document[:owner].nil?
    
      ## Store file extension
      document_extension = document[:datafile].original_filename.split(".").last unless document[:datafile].blank?
    
      ## affect document_name with original document name if associated textfield is undefined 
      document[:name].blank? ? document_name = ((a = document[:datafile].original_filename.split("."); a.pop; a.to_s) unless document[:datafile].blank?) : document_name = document[:name]
    
      @document =super(
        :name => document_name , 
        :description => document[:description], 
        :extension => document_extension)
      @document.file_type = FileType.find(document[:file_type_id]) unless document[:file_type_id].nil?
      @document.owner = document[:owner]
      #    @document.tag_list = document[:tag_list].split(",") unless document[:tag_list].nil?
      @document.file = document[:datafile] unless document[:datafile]. blank?
#      document[:owner].documents << @document
      return @document
    else
      raise "Document require owner attribute. example : Document.new(:owner => Employee.last)"
    end
  end
  
  def self.create_all(documents, owner)
    if documents.keys.size.to_i > 0
      document_objects = []
      documents.keys.size.to_i.times do |i|
        unless documents["#{i+1}"][:valid] == "false"
          documents["#{i+1}"][:owner] = owner
          document_objects << Document.new(documents["#{i+1}"])
        end
      end
      return document_objects
    end   
  end
  
  ## Override update
  def update_attributes(document = nil)
    unless document.nil?
      unless document[:upload].nil?
        ## Store tags list
        tag_list = document.delete("tag_list").split(",")

        ## Creation of document_version          
        path = "documents/" + self.path + "/" +  self.id.to_s + "/"
        file_response = FileManager.upload_file(:file => document[:upload], :name => (self.document_versions.size + 1).to_s + "." +document[:upload][:datafile].original_filename.split(".").pop, 
          :directory => path, :extensions => [self.extension])
        if file_response
          @document_version = DocumentVersion.create(:name => self.name, :description => self.description, :versioned_at => self.updated_at)      
        
          ## Add tag_list for document
          self.tag_list = tag_list
          
          document.delete("upload")
          self.document_versions << @document_version
          @document_version.create_thumbnails(self.id)
          super(document)
          return true
        end      
      else
        return false
      end
      unless file_response     
      else
        return false
      end
    else
      super
    end
  end
  
  ## Override save methods
  def save()
    if self.owner.valid?
        
      unless self.file.nil?
        unless self.file.blank?
        
          ## Store all possible extension for file
          possible_extensions = []
          self.file_type.file_type_extensions.each {|f| possible_extensions << f.name}
          
          if super
            
            path = "documents/" + self.owner.class.name.downcase + "/" + self.file_type.id.to_s.downcase + "/"
            file_response = FileManager.upload_file(:file => {:datafile => self.file}, :name => self.id.to_s+"."+ self.file.original_filename.split(".").last, 
              :directory => path, :extensions => possible_extensions)
            
            ## If file succefuly create
            if file_response
          
              ## Add tag_list for document
              unless self.tag_list.nil?
                self.tag_list.each {|tag| self.tag_list << tag.strip} 
                #FIXME Verify if it's necessary
                self.tag_list.uniq!
              end
              return true              
            else
              self.destroy
            end
          end          
        else
          return false
        end
      else
        return false
      end ## file.nil?
    else
      return false
    end ## owner.valid?
  end
  
end
