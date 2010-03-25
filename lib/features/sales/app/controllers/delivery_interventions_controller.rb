class DeliveryInterventionsController < ApplicationController
  #helper :orders, :contacts, :delivery_interventions
  helper :delivery_notes
  
  acts_as_step_controller :step_name => :delivery_step, :skip_edit_redirection => true
  
  before_filter :find_delivery_note, :find_delivery_intervention
  
  ## GET /orders/:order_id/:step/delivery_notes/:delivery_note_id/delivery_interventions/:id
  def show
  end
  
  # GET /orders/:order_id/:step/delivery_notes/:delivery_note_id/delivery_interventions/:delivery_intervention_id/report
  def report
    if @delivery_intervention and @delivery_intervention.delivered? and @delivery_intervention.report_file_name
      url = @delivery_intervention.report.path
      ext = File.extname(url)
      
      send_data File.read(url), :filename    => "rapport_intervention_#{@delivery_intervention.id}#{ext}",
                                :type        => @delivery_intervention.report_content_type,
                                :disposition => 'attachment'
    else
      error_access_page(404)
    end
  end
  
  private
    def find_delivery_note
      if params[:delivery_note_id]
        @delivery_note = DeliveryNote.find(params[:delivery_note_id])
        error_access_page(404) unless @order and @order.delivery_notes.include?(@delivery_note)
      end
    end
    
    def find_delivery_intervention
      if id = params[:id] || params[:delivery_intervention_id]
        @delivery_intervention = DeliveryIntervention.find(id)
        error_access_page(404) unless @delivery_note and @delivery_note.delivery_interventions.include?(@delivery_intervention)
      end
    end
  
end
