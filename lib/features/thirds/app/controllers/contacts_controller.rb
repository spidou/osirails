class ContactsController < ApplicationController
  
  helper :employees
  
  protect_from_forgery :except => [:auto_complete_for_contact_first_name]  
  
  def show
    if Contact.can_view?(current_user)
      if params[:owner_type]
        @owner_type = params[:owner_type]
        @owner = @owner_type.split("/").last.constantize.find(params["#{@owner_type.split("/").last.downcase}_id"])
        @contact = Contact.find(params[:id])
      else
        error_access_page(404)
      end
    else
      error_access_page(403)
    end
  end
  
  def edit
    if Contact.can_edit?(current_user)
      if params[:owner_type]
        @contact = Contact.find(params[:id])
        @owner_type ||= params[:owner_type]
        @numbers = @contact.numbers
        @owner = params[:owner_type].constantize.find(params["#{params[:owner_type].downcase}_id"])
      else
        error_access_page(404)
      end
    else
      error_access_page(403)
    end
  end
  
  def update
    if Contact.can_edit?(current_user)
      @owner = params[:contact][:owner_type].constantize.find(params["#{params[:contact][:owner_type].downcase}_id"])
      @contact = Contact.find(params[:id])
      @owner_type  = params[:contact][:owner_type]
      @numbers_reloaded||= nil
      @numbers_reloaded.nil? ? @numbers = @contact.numbers : @numbers = @numbers_reloaded
      
#      if params[:owner_type]  == "Customer"
#        @owner =Customer.find(params["#{params[:owner_type].downcase}_id"])
#      elsif params[:owner_type]  == "Establishment"
#        @owner =Establishment.find(params[:owner])
#      elsif params[:owner_type]  == "Supplier"
#        @owner =Supplier.find(params[:owner])
#      end
      
      # put numbers another place for a separate creation
      params[:numbers] = params[:contact]['numbers']
      params[:contact].delete('numbers')
      
      # add or update numbers who have been send to the controller
      params[:numbers].each_key do |i|
        if @contact.numbers[i.to_i].nil?
          params[:numbers][i]['visible'] = false if params[:numbers][i]['visible'].nil?
          @contact.numbers[i.to_i] =  Number.new(params[:numbers][i]) unless params[:numbers][i].nil? or params[:numbers][i].blank?
        else
          params[:numbers][i]['visible'] = false if params[:numbers][i]['visible'].nil?  
          @contact.numbers[i.to_i].update_attributes(params[:numbers][i]) unless params[:numbers][i].nil? or params[:numbers][i].blank?
        end
      end 
    
      contact = params[:contact].dup
      contact.delete("numbers")
      contact.delete("owner_type")
    
      # update contact ressources
      unless @contact.update_attributes(contact)
        @error = true
      end

      if @error
        @numbers.each_with_index do |number,index|
          unless params[:deleted_numbers].nil?
            params[:deleted_numbers].each_value do |j|
               @numbers[index]['number']= "deleted" if @numbers[index]['id'].to_s == j.to_s  
            end
          end  
        end
        
        @numbers_reloaded = @numbers
        params[:contact]['numbers'] = params[:numbers]
        
        flash[:error] = "Une erreur est survenu lors de la modification du contact"
        render :controller => [@owner, @contact], :action => "edit"
      else
        # destroy the numbers that have been deleted in the update view
        unless  params[:deleted_numbers].nil?
          params[:deleted_numbers].each_value do |i|
            @contact.numbers.each_index do |j|
              @contact.numbers[j].destroy if  @contact.numbers[j]['id'].to_s == i.to_s
            end
          end
        end
        
        flash[:notice] = "Contact modifi&eacute; avec succ&egrave;s"
        redirect_to(eval("#{@owner.class.name.tableize.singularize}_contact_path(@owner, @contact, :owner_type => '#{params[:contact][:owner_type]}')"))
      end
    else
      error_access_page(403)
    end
  end
  
  def destroy
    if Contact.can_delete?(current_user)
      @contact = Contact.find(params[:id])
    
      raise @contact.contacts_owners.inspect
      @owner_type = params.keys.last
      raise @owner_type
      @owner_id = params["#{@owner_type}_id"]

      eval "@owner =#{@owner_type.capitalize}.find(@owner_id)"
    
      @owner.contacts.delete(@contact)
      flash[:notice] = "Contact supprim&eacute; avec succ&egrave;s"
      redirect_to :back 
    else
      error_access_page(403)
    end
  end
  
  def auto_complete_for_contact_first_name
    auto_complete_responder_for_first_name(params[:owner_id], params[:owner_type], params[:value])  
  end
  
  def auto_complete_responder_for_first_name(owner_id, owner_type, value)
    @contacts = []
    
    @owner = owner_type.constantize.find(owner_id)
    Contact.find(:all).each do |contact|
      if @contacts.size < 10
        if contact.first_name.downcase.grep(/#{value.downcase}/).length > 0
          @contacts << contact
        end
      end
    end
    @contacts = @contacts.uniq
    render :partial => 'contacts/contact_info'
  end
  
  def auto_complete_for_contact_last_name
    auto_complete_responder_for_last_name(params[:owner_id], params[:owner_type], params[:value])  
  end
  
  def auto_complete_responder_for_last_name(owner_id, owner_type, value)
    @contacts = []
    
    @owner = owner_type.constantize.find(owner_id)
    Contact.find(:all).each do |contact|
      if @contacts.size < 10
        if contact.last_name.downcase.grep(/#{value.downcase}/).length > 0
          @contacts << contact
        end
      end
    end
    
    @contacts = @contacts.uniq
    render :partial => 'contacts/contact_info'
  end
  
  def auto_complete_for_contact_email
    auto_complete_responder_for_email(params[:owner_id], params[:owner_type], params[:value])  
  end
  
  def auto_complete_responder_for_email(owner_id, owner_type, value)
    @contacts = []
    
    @owner = owner_type.constantize.find(owner_id)
    Contact.find(:all).each do |contact|
      if contact.email.downcase.grep(/#{value.downcase}/).length > 0
        @contacts << contact
      end
    end
    
    @contacts = @contacts.uniq
    render :partial => 'contacts/contact_info'
  end
  
end