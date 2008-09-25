class DocumentsController < ApplicationController
  
  def show
    @document = Document.find(params[:id])
    #    if Document.can_view?(current_user, @document.owner_class.capitalize)   
    @document_versions = @document.document_versions
    @document_version = DocumentVersion.new()
    #    else
    #      error_access_page(403)
    #    end
  end
  
  def edit
    @document = Document.find(params[:id])
    #    if Document.can_edit?(current_user, @document.owner_class.capitalize)
    @document_last_version =@document.document_versions.last
    #    else
    #      error_access_page(403)
    #    end
  end
  
  def update
    @document = Document.find(params[:id])
    #    if Document.can_edit?(current_user, @document.owner_class.capitalize)
    unless params[:upload][:datafile].blank?
      params[:document][:upload] = params[:upload]
      @document.update_attributes(params[:document])
      params[:document].delete("tag_list")
      params[:document].delete("upload")
      @document.update_attributes(params[:document])        
     
    else
      @error = true
      flash[:error] = "Fichier manquant"
    end
    
    unless @error
      eval "redirect_to #{@document.owner_class}_document_path(@document.has_document, @document)"
    else
      render :controller => [@document.has_document, @document], :action => "edit" 
    end
    #    else
    #      error_access_page(403)
    #    end
  end
  
  ## This method return the image to show
  def preview_image
    puts "ppppppppppppppppppppppppppppppppppppppppppppppppp"
##    puts path 
    model = params[:model]
    @document = model.constantize.find(params[:id])
    #    if Document.can_view?(current_user, @document.owner_class.capitalize)
    
    path = "documents/#{@document.path}#{@document.id}.#{@document.extension}"
#    path = "documents/customer/9/1.jpeg"

    require 'RMagick'

#    clown = Magick::Image.read(path).first
#    clown.crop_resized!(75, 75, Magick::NorthGravity)
#    clown.write('crop_resized.jpg')

    
    img=File.read(path)
    send_data(img, :filename =>'workshopimage', :type => "image/jpeg", :disposition => "inline")
#    send_data(clown, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
    #    end
  end
  
  def thumbnail 
    @document = Document.find(params[:id])
    #    if Document.can_view?(current_user, @document.owner_class.capitalize)
    path = "documents/#{@document.owner_class.downcase}/#{@document.file_type_id}/#{@document.id}_75_75.jpeg"
    img=File.read(path)
    send_data(img, :filename =>'workshopimage', :type => "image/jpg", :disposition => "inline")
    #    end
  end
  
end
