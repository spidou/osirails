class ContactAvatarsController < ApplicationController
  
  # GET /contacts/:id/avatar
  #
  def show
    @contact = Contact.find(params[:id])
    
    if Contact.can_view?(current_user)
      ext = File.extname(@contact.avatar.path(:thumb))
      dir = File.dirname(@contact.avatar.path(:thumb))
      url = "#{dir}/thumb#{ext}"
      url = File.exists?(url) ? url : @contact.avatar
      
      send_data File.read(url), :filename => "#{@contact.id}_#{@contact.avatar_file_name}", :type => @contact.avatar_content_type, :disposition => 'inline'
    end
  end
  
end
