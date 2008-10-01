module JobContractsHelper
  def job_contract_type_select(default_job_contract)
    is_gone?(default_job_contract) ? disabled = "disabled='disabled'" : disabled=""
    html= "<select #{disabled} onchange=is_limited(this) id='job_contract_job_contract_type_id' name='job_contract[job_contract_type_id]'>"
    
    JobContractType.find(:all).each do |job_contract|      
      if default_job_contract.nil?  
        params[:job_contract][:job_contract_type_id]== job_contract.id ? selected = "selected='selected'" : selected = ""
      else
        default_job_contract[:job_contract_type_id]== job_contract.id ? selected = "selected='selected'" : selected = ""
      end    
      html+= "<option value='#{job_contract.id}'#{selected} title='#{job_contract.name},#{job_contract.limited}'>#{job_contract.name}</option>"
    end
    html+= "</select>"
  end
  
  def employee_state_inactive(default_job_contract)
    is_gone?(default_job_contract) ? disabled = "" : disabled = "disabled='disabled'"
    html="<select id='job_contract_employee_state_inactive' name='job_contract[employee_state_inactive]' #{disabled}>"
      EmployeeState.find(:all,:conditions => ["active=?",0]).each do |state|
        if default_job_contract.nil?  
          params[:job_contract][:employee_state_id]== state.id ? selected = "selected='selected'" : selected = ""
        else
          default_job_contract[:employee_state_id]== state.id ? selected = "selected='selected'" : selected = ""
        end
        html+="<option value='#{state.id}' #{selected} >#{state.name}</option>"
      end
    html+="</select>"
  end
  
  def is_gone?(job_contract)
    return false if job_contract.nil?
    return !job_contract.employee_state.active unless job_contract.employee_state.nil?
  end
  
end
