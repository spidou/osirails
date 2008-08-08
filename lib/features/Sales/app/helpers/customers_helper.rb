module CustomersHelper
  def establishment_name
    text_field "new_establishment#{params[:cpt]}", :name
  end
  
  def establishment_type
    select("establishment#{establishment.id}", "establishment_type_id",EstablishmentType.find(:all).collect {|a| [ a.wording, a.id ] },:selected => establishment.establishment_type_id)
  end
  
  def address1
    text_field "new_address#{params[:cpt]}", :name
  end
  
  def new_link
    link_to_remote("Valider", :url => {:action => "add_form", :cpt => params[:cpt].to_i+1})
  end
end