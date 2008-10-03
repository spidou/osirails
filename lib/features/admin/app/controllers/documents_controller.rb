class DocumentsController < ApplicationController
  
  def show
    @document = Document.find(params[:id])
    @javascript = "<script langage='javascript'> parent.document.getElementById('testpage').innerHTML = document.getElementById('testpage').innerHTML</script>"
    render( :layout => false, :partial => 'documents/edit_partial', :locals => {:document => @document, :javascript => @javascript})
  end
  
  def update
    params[:page] ||= 1
    @document = Document.find(params[:id])
    #    if Document.can_edit?(current_user, @document.owner_class.capitalize)
    params[:document][:upload] = params[:upload]
    ## Create firs version
    if @document.document_versions.empty?
      hash = {:upload => {:datafile => File.open(("documents/" + @document.path + @document.id.to_s+ "." + @document.extension), "r")}, :name => "1"}
      @document.update_attributes(hash)
    end
    
    @document.update_attributes(params[:document])
    @javascript = "<script langage='javascript'> parent.document.getElementById('testpage').innerHTML = document.getElementById('testpage').innerHTML</script>"
    
    render( :layout => false, :partial => 'documents/edit_partial', :locals => {:document => @document, :javascript => @javascript})
  end
  
  ## This method return the image to show
  def preview_image
    model = params[:model]
    @document = model.constantize.find(params[:id])
    #    if Document.can_view?(current_user, @document.owner_class.capitalize)
    
    path = "documents/#{@document.path}#{@document.id}_770_450.#{@document.extension}"
    
    img=File.read(path)
    send_data(img, :filename =>'workshopimage', :type => "image/jpeg", :disposition => "inline")
    #    end
  end
  
  def thumbnail 
    @document = Document.find(params[:id])
    path = "documents/#{@document.path}#{@document.id}_75_75.#{@document.extension}"
    img=File.read(path)
    send_data(img, :filename =>'workshopimage', :type => "image/jpeg", :disposition => "inline")
    #    end
  end
  
end
