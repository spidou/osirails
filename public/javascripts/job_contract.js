function skip_date()
{ 
  if( document.getElementById('job_contract_end_date_3i').disabled == false)
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
