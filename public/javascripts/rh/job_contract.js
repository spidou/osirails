function skip_date(disabled_state)
{ 
  if( disabled_state == true)
  {
    document.getElementById('job_contract_end_date_3i').disabled = true;
    document.getElementById('job_contract_end_date_2i').disabled = true;
    document.getElementById('job_contract_end_date_1i').disabled = true;
  }
  else
  {
    document.getElementById('job_contract_end_date_3i').disabled = false;
    document.getElementById('job_contract_end_date_2i').disabled = false;
    document.getElementById('job_contract_end_date_1i').disabled = false;
  }
}

function is_limited(select)
{
  if (select.options[select.selectedIndex].title.split(",")[1]=='true')
  {
    skip_date(false);
  }
  else if (select.options[select.selectedIndex].title.split(",")[1]=='false')
  {
    skip_date(true);
  }
}

function disable_all()
{
  tab = ['job_contract_end_date_3i','job_contract_end_date_2i','job_contract_end_date_1i','job_contract_start_date_3i','job_contract_start_date_2i','job_contract_start_date_1i','job_contract_job_contract_type_id','job_contract_employee_state_id','job_contract[salary_attributes][gross_amount]','job_contract_salary_attributes__type_value']
  if (document.getElementById('employee_departure').checked==true)
  {
    for(i=0;i<tab.length;i++)
    {
      document.getElementById(tab[i]).disabled = true;
    }
    document.getElementById('job_contract_employee_state_inactive').disabled = false;
    document.getElementById('job_contract_departure_3i').disabled = false;
    document.getElementById('job_contract_departure_2i').disabled = false;
    document.getElementById('job_contract_departure_1i').disabled = false;
    document.getElementById('employee_departure_form').style.display="block";
  }
  else
  {
    for(i=0;i<tab.length;i++)
    {
      document.getElementById(tab[i]).disabled = false;
    }
    document.getElementById('job_contract_employee_state_inactive').disabled = true;
    document.getElementById('job_contract_departure_3i').disabled = true;
    document.getElementById('job_contract_departure_2i').disabled = true;
    document.getElementById('job_contract_departure_1i').disabled = true;
    document.getElementById('employee_departure_form').style.display="none";
  }
  
}
