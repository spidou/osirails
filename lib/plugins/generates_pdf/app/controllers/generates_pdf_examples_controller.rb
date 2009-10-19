class GeneratesPdfExamplesController < ApplicationController
  
  # GET /show
  def show
    @representative = Employee.find(params[:id])
    render  :pdf => "example_with_"+@representative.first_name.downcase+"_"+@representative.last_name.downcase, 
            :template => "generates_pdf_examples/show.xml.erb",
            :xsl => "devis"
  end  
end
