class ContactsController < ApplicationController
  
    protect_from_forgery :except => [:auto_complete_for_contact_first_name]
  
  def edit

    @contact = Contact.find(params[:id])
    @owner_type  =params[:owner_type]
    unless params[:owner].nil?
      @owner = params[:owner]
    end
    if @owner_type  == "Customer"
      @owner = Customer.find(params[:customer_id])
      @possible_owners = Customer.find(:all)
      @contact_type = "Customer"
    elsif @owner_type == "Supplier"
      @owner = Supplier.find(params[:customer_id])
      @possible_owners = Supplier.find(:all)
      @contact_type = "Supplier"
    elsif @owner_type == "Establishment"
      @owner = Establishment.find(params[:customer_id])
      @possible_owners = Establishment.find(:all)
      @contact_type = "Establishment"
    end
    
  end
  
  def update

    @contact = Contact.find(params[:id])
    if params[:owner_type]  == "Customer"
      @owner =Customer.find(params[:owner])
    elsif params[:owner_type]  == "Establishment"
      @owner =Establishment.find(params[:owner])
    elsif params[:owner_type]  == "Supplier"
      @owner =Supplier.find(params[:owner])
    end

    @contact.update_attributes(params[:contact])
    
    #FIXME Change this redirect_to by render
    redirect_to(edit_customer_contact_path(@owner,@contact,:owner_type => params[:owner_type]))
  end
  
  def destroy

    @contact = Contact.find(params[:id])
    
    @owner_type = params.keys.last.slice(0..-4)
    
    if params[:owner_type]  == "Customer"
      @owner =Customer.find(params[:owner])
    elsif params[:owner_type]  == "Establishment"
      @owner =Establishment.find(params[:owner])
    elsif params[:owner_type]  == "Supplier"
      @owner =Supplier.find(params[:owner])
    end

    @contact.destroy

    eval("redirect_to(edit_#{@owner_type}_path(params[:customer_id]))")
     
  end
  
  def auto_complete_for_contact_first_name    
    auto_complete_responder_for_first_name(params[:owner_id], params[:value])  
  end
  
  def auto_complete_responder_for_first_name(owner_id,value)
    @contacts = []
    @owner = Customer.find(owner_id)
    if @owner.contacts.length > 0
      @owner.contacts.each do |owner_contact|
        if owner_contact.first_name.downcase.grep(/#{value.downcase}/).length > 0
          @contacts << owner_contact
        end
      end
    end
    
    if @owner.establishments.length > 0
      @owner.establishments.each do |establishment|
        establishment.contacts.each do |establishment_contact|
          if establishment_contact.downcase.first_name.grep(/#{value.downcase}/).length > 0
            @contacts << establishment_contact
          end
        end
      end
    end
    render :partial => 'contacts/first_name'
  end
  
  def auto_complete_for_contact_last_name
    auto_complete_responder_for_last_name(params[:owner_id], params[:value])  
  end
  
  def auto_complete_responder_for_last_name(owner_id,value)
    @contacts = []
    @owner = Customer.find(owner_id)
    if @owner.contacts.length > 0
      @owner.contacts.each do |owner_contact|
        if owner_contact.last_name.downcase.grep(/#{value.downcase}/).length > 0
          @contacts << owner_contact
        end
      end
    end
    
    if @owner.establishments.length > 0
      @owner.establishments.each do |establishment|
        establishment.contacts.each do |establishment_contact|
          if establishment_contact.last_name.downcase.grep(/#{value.downcase}/).length > 0
            @contacts << establishment_contact
          end
        end
      end
    end
    render :partial => 'contacts/first_name'
  end
  
  def auto_complete_for_contact_email
    auto_complete_responder_for_email(params[:owner_id], params[:value])  
  end
  
  def auto_complete_responder_for_email(owner_id,value)
    @contacts = []
    @owner = Customer.find(owner_id)
    if @owner.contacts.length > 0
      @owner.contacts.each do |owner_contact|
        if owner_contact.email.downcase.grep(/#{value.downcase}/).length > 0
          @contacts << owner_contact
        end
      end
    end
    
    if @owner.establishments.length > 0
      @owner.establishments.each do |establishment|
        establishment.contacts.each do |establishment_contact|
          if establishment_contact.email.downcase.grep(/#{value.downcase}/).length > 0
            @contacts << establishment_contact
          end
        end
      end
    end
    render :partial => 'contacts/first_name'
  end
  
end