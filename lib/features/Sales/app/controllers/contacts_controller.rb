class ContactsController < ApplicationController
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
end