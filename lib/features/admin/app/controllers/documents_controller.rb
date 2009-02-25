class DocumentsController < ApplicationController
  
  # GET /:document_owner/1/documents
  # 
  # ==== Examples
  #   GET /customers/1/documents
  #   GET /employees/1/documents
  #
  def index
    # params.collect{ |x, y| x.to_s.grep(/_id/).to_s }
    @documents = Customer.find(params[:customer_id]).documents
    
    @group_by = params[:group_by] || "date"
    @order_by = params[:order_by] || "asc" # ascendent

    case @group_by
    when "type"
      @groups = @documents.to_enum.group_by{ |d| d.file_type.name }
    when "name"
      @groups = { :the_only_one => @documents.sort_by{ |d| d.name } }
    when "tag"
      #OPTIMIZE fix the bug when a document has multiple tags
      @groups = @documents.to_enum.group_by{ |d| d.tags.collect{ |t| t.name } }
    else # group by date by default
      @groups = @documents.sort_by{ |d| d.created_at }.to_enum.group_by{ |d| @template.time_ago_in_words(d.created_at) }.reverse # reverse because by default we want to display the earlier to the later
    end

    @groups.reverse! if @order_by == "desc"
    
    render :layout => false
  end
  
#  def show
#    @document = Document.find(params[:id])
#    @javascript = "<script langage='javascript'> parent.document.getElementById('testpage').innerHTML = document.getElementById('testpage').innerHTML</script>"
#    render( :layout => false, :partial => 'documents/edit_partial', :locals => {:document => @document, :javascript => @javascript})
#  end
#  
#  def update
#    params[:page] ||= 1
#    @document = Document.find(params[:id])
#    #    if Document.can_edit?(current_user, @document.owner_class.capitalize)
#    params[:document][:upload] = params[:upload]
#    ## Create firs version
#    if @document.document_versions.empty?
#      hash = {:upload => {:datafile => File.open(("documents/" + @document.path + @document.id.to_s+ "." + @document.extension), "r")}, :name => "1"}
#      @document.update_attributes(hash)
#    end
#    
#    @document.update_attributes(params[:document])
#    @javascript = "<script langage='javascript'> parent.document.getElementById('testpage').innerHTML = document.getElementById('testpage').innerHTML</script>"
#    
#    render( :layout => false, :partial => 'documents/edit_partial', :locals => {:document => @document, :javascript => @javascript})
#  end
#  
#  ## This method return the image to show
#  def preview_image
#    model = params[:model]
#    @document = model.constantize.find(params[:id])
#    #    if Document.can_view?(current_user, @document.owner_class.capitalize)
#    
#    path = "documents/#{@document.path}#{@document.id}_770_450.#{@document.extension}"
#    
#    img=File.read(path)
#    send_data(img, :filename =>'workshopimage', :type => "image/jpeg", :disposition => "inline")
#    #    end
#  end
#  
#  def thumbnail 
#    @document = Document.find(params[:id])
#    path = "documents/#{@document.path}#{@document.id}_75_75.#{@document.extension}"
#    img=File.read(path)
#    send_data(img, :filename => 'workshopimage', :type => "image/jpeg", :disposition => "inline")
#    #    end
#  end
  
end
