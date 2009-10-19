ActionController::Routing::Routes.add_routes do |map|
  map.generates_pdf_examples 'generates_pdf_examples/:id',  :controller => 'generates_pdf_examples', :action => 'show' 
end
