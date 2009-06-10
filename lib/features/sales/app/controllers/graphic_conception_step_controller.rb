class GraphicConceptionStepController < ApplicationController
  helper :documents, :press_proofs
  
  acts_as_step_controller :step_name => :graphic_conception_step
  
  def show
    respond_to do |format|
      format.html {}
      format.pdf {
        data = render_to_string(:action => "show.pdf.erb", :layout => false)
        pdf = PDF::HTMLDoc.new
        pdf.set_option :bodycolor, 'white'
        pdf.set_option :toc, false
        pdf.set_option :charset, 'utf-8'
        pdf.set_option :portrait, true
        pdf.set_option :links, false
        pdf.set_option :webpage, true
        pdf.set_option :left, '1cm'
        pdf.set_option :right, '1cm'
        pdf.set_option :textcolor, 'black'
        
        pdf << data
        @step.documents.each do |document|
          # document.convert_to_png
          pdf << "<h2 align=\"center\">#{document.name}</h2><br /><div align=\"center\"><img src=\"#{document.attachment.path(:medium)}\" /></div>"
        end
        
        pdf.footer "./."
        
        send_data pdf.generate, :filename => "bon_a_tirer_#{@order.id}.pdf"
      }
    end
  end
  
  def edit
  end
  
  def update
    if @step.update_attributes(params[:graphic_conception_step])
      flash[:notice] = "L'étape a été modifié avec succès"
    end
    render :action => :edit
  end
  
end
