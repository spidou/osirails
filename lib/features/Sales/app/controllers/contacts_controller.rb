class ContactsController < ApplicationController
  
  helper :employees
  
  protect_from_forgery :except => [:auto_complete_for_contact_first_name]
  
  
  def show 
    if Contact.can_view?(current_user)
      @owner_type  = params[:owner_type]
      @owner = params[:owner_type].constantize.find(params["#{params[:owner_type].downcase}_id"])
      @contact = Contact.find(params[:id])
    end
  end
  
  def edit
    @contact = Contact.find(params[:id])
    @owner_type  ||= params[:owner_type]

    @owner = params[:owner_type].constantize.find(params["#{params[:owner_type].downcase}_id"])

  end
  
  def update
    @owner = params[:owner_type].constantize.find(params["#{params[:owner_type].downcase}_id"])
    @contact = Contact.find(params[:id])
    if params[:owner_type]  == "Customer"
      @owner =Customer.find(params[:owner])
      owner_path = "customer_path(@owner)"
    elsif params[:owner_type]  == "Establishment"
      @owner =Establishment.find(params[:owner])
      owner_path = "establishent_path(@owner)"
    elsif params[:owner_type]  == "Supplier"
      @owner =Supplier.find(params[:owner])
      owner_path = "supplier_path(@owner)"
    end
    
    # put numbers another place for a separate creation
    #    puts params[:contact].keys
    params[:numbers] = params[:contact]['numbers']
    params[:contact].delete('numbers')
    puts params[:numbers]
    
    # update contact ressources
    unless @contact.update_attributes(params[:contact])
      params[:contact]['numbers'] = params[:numbers]
      flash[:error] = "Une erreur est survenu lors de la modification du contact"
      @error = true
      @owner
      render :action => "edit"
    else
      params[:numbers].each do |number|
        @contact.numbers << Number.new(number[1]) unless number[1].nil? or number[1].blank?
      end
      #      params[:contact]['numbers'] = params[:numbers]
      flash[:notice] = "Contact modifi&eacute; avec succ&egrave;s"
      eval "redirect_to #{owner_path}"
    end
  end
  
  def destroy
    @contact = Contact.find(params[:id])
    
    @owner_type = params.keys.last.slice(0..-4)
    @owner_id = params["#{@owner_type}_id"]

    eval "@owner =#{@owner_type.capitalize}.find(@owner_id)"
    
    @owner.contacts.delete(@contact)
    flash[:notice] = "Contact supprim&eacute; avec succ&egrave;s"
    redirect_to :back  
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