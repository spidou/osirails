class DocumentsController < ApplicationController
  
  def show
    @document = Document.find(params[:id])
    
    @document_versions = @document.document_versions
    @document_version = DocumentVersion.new()
  end
  
  def edit
    @document = Document.find(params[:id])
    @document_last_version =@document.document_versions.last
  end
  
  def create
    unless params[:upload][:datafile].blank?
      
      ## Store tags list
      

      ## Store file extension and name
      document_extension = params[:upload][:datafile].original_filename.split(".").last
      params[:document][:name].blank? ? document_name = (a = params[:upload][:datafile].original_filename.split("."); a.pop; a.to_s) : document_name = params[:document][:name]
      
      if @document =Document.create(:name => document_name , :description => params[:document][:description], :extension => document_extension)
        @document.file_type = FileType.find(params[:document][:file_type_id])
        
        ## Store all possible extension for file
        possible_extensions = []
        @document.file_type.file_type_extensions.each {|f| possible_extensions << f.name}
        
        path = "documents/" + params[:owner][:owner_model].downcase + "/" + params[:document][:file_type_id].downcase + "/"
        file_response = FileManager.upload_file(:file => params[:upload], :name =>@document.id.to_s+"."+document_extension, 
          :directory => path, :extensions => possible_extensions)
        
        ## If file succefuly create
        if file_response
          ## Add Document to owner
          @owner = params[:owner][:owner_model].constantize.find(params[:owner][:owner_id])
          @owner.documents << @document
          
          ## Create thumbnails
          @document.create_thumbnails
          
        else
          @document.destroy
          flash[:error] = "Une erreur est survenue lors de la sauvegarde du fichier. Vérifier que l'extension du fichier uploadé est bien valide.\n Si le problème persiste veuillez contacté votre administrateur réseau" 
        end
        
      end
    else
      flash[:error] = "Fichier manquant"
    end
    redirect_to :back
  end
  
  
  def update
    @document = Document.find(params[:id])
    unless params[:upload][:datafile].blank?
      
      ## Store possible extensions
      possible_extensions = []
      possible_extensions << @document.extension

      ## Creation of document_version          
      path = "documents/" + @document.path + "/" +  @document.id.to_s + "/"
      file_response = FileManager.upload_file(:file => params[:upload], :name => (@document.document_versions.size + 1).to_s + "." +params[:upload][:datafile].original_filename.split(".").pop, 
        :directory => path, :extensions => possible_extensions)
      unless file_response
        flash[:error] = "Une erreur est survenue lors de la sauvegarde du fichier. Vérifier que l'extension du fichier uploadé est bien valide"
      else
        @document_version = DocumentVersion.create(:name => @document.name, :description => @document.description, :versioned_at => @document.updated_at)      
        
        @document.update_attributes(params[:document])          
        @document.document_versions << @document_version
        @document_version.create_thumbnails
      end      
    else
      flash[:error] = "Fichier manquant"
    end
    
    unless file_response     
      render :action => "edit"
    else
      flash[:notice] = "Fichier upload&eacute; avec succ&egrave;s"
      redirect_to [@document.has_document, @document]
    end
  end
  
  ## This method return the image to show
  def preview_image
    @document = Document.find(params[:id])
    path = "documents/#{@document.owner_class.downcase}/#{@document.file_type_id}/#{@document.id}.jpg"
    img=File.read(path)
    @var = send_data(img, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
  end
  
  def thumbnail 
    @document = Document.find(params[:id])
    path = "documents/#{@document.owner_class.downcase}/#{@document.file_type_id}/#{@document.id}_75_75.jpg"
    img=File.read(path)
    @var = send_data(img, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
  end
  
end
