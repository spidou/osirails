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
  
  def update
    unless params[:upload][:datafile].blank?
      @document = Document.find(params[:document_id])
      @owner  = @document.has_document
      
      ## Store possible extensions
      @possible_extensions = []
      @document.file_type.file_type_extensions.each {|f| @possible_extensions << f.name}
    
      puts "test"
      puts @possible_extensions
      ## Creation of document_version
      if @document_version = DocumentVersion.create(:description => params[:document_version][:description])      
        path = "documents/" + @owner.class.name.downcase + "/" + @document.file_type_id.to_s + "/" + @document.id.to_s
      
        FileManager.upload_file(:file => params[:upload], :name =>@document_version.id.to_s+"."+@document.extension, 
          :directory => path, :extensions => @possible_extensions)
        @document.document_versions << @document_version
      end
    end   
  end
  
  def preview_image
    @document = Document.find(params[:id])
    path = "documents/#{@document.has_document.class.name.downcase}/#{@document.file_type_id}/#{@document.id}.jpg"
    img=File.read(path)
    @var = send_data(img, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
  end
  
end
