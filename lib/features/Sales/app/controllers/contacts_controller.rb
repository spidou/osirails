class ContactsController < ApplicationController
  def edit
    @contact = Contact.find(params[:id])
    @customer = Customer.find(params[:customer_id])
    
    if @contact.has_contact_type  == "Third"      
        if Third.find(@contact.has_contact_id).class.name == "Customer"
          @owner = Customer.find(:all)
          @contact_type = "Customer"
        elsif Third.find(@contact.has_contact_id).class.name == "Supplier"
          @owner = Supplier.find(:all)
          @contact_type = "Supplier"
        end       
    elsif @contact.has_contact_type == "Establishment"
        @owner = Establishment.find(:all)
        @contact_type = "Establishment"
    end
  end
  
  def index
  end
  
  def update
    @contact = Contact.find(params[:id])
    @customer = Customer.find(params[:customer_id])
    if params[:contact][:has_contact_type] == "Customer" or params[:contact][:has_contact_type] == "Supplier"
      params[:contact][:has_contact_type] = "Third"
    end
    @contact.update_attributes(params[:contact])
    
    #FIXME Change this redirect_to by render
    redirect_to(edit_customer_contact_path(@customer,@contact))
  end
  
  def contact_owner_change
  end
  
  def delete
    
  end
end