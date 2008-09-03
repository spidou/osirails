class DocumentsController < ApplicationController
  
  def show
    @document = Document.find(params[:id])
    @document_versions = @document.document_versions
    @document_version = DocumentVersion.new()
  end
  
  def create
    unless params[:upload][:datafile].blank?
      
      ## Store file extension and title
      document_extension = params[:upload][:datafile].original_filename.split(".").last
      params[:document][:title].blank? ? document_title = params[:upload][:datafile].original_filename : document_title = params[:document][:title]
      
      if @document =Document.create(:title => document_title , :description => params[:document][:description], :extension => document_extension)
        @document.file_type = FileType.find(params[:document][:file_type_id])
        
        ## Store all possible extension for file
        possible_extensions = []
        @document.file_type.file_type_extensions.each {|f| possible_extensions << f.name}
        
        path = params[:owner][:owner_model].downcase + "/" + params[:document][:file_type_id].downcase + "/"
        FileManager.upload_file(:file => params[:upload], :name =>@document.id.to_s+"."+document_extension, 
          :directory => "documents/#{path}", :extensions => possible_extensions)
        
        ## Add Document to owner
        eval <<-EOV
        @owner = #{params[:owner][:owner_model]}.find(#{params[:owner][:owner_id]})
        @owner.documents << @document
        EOV
      end
    end
  end
  
  def edit
    
  end
  
  def update
    @document = Document.find(params[:id])
    @owner  = @document.has_document
    @possible_extensions = @document.file_type.file_type_extensions
    
    ## Creation of document_version
    unless @document_version = DocumentVersion.create()      
      path = "documents/" + @owner.class.name.downcase + "/" + @document.file_type_id + "/" + @document.id
      
      FileManager.upload_file(:file => params[:upload], :name =>@document_version.id.to_s+"."+@document.extension, 
        :directory => path, :extensions => @possible_extensions)
    end
    
  end
  
  def preview_image
    img=File.read("documents/customer/9/4.jpg")
    @var = send_data(img, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
  end
  
end
