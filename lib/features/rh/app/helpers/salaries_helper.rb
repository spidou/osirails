module SalariesHelper

  def net(brut)
  # TODO code the net method to determine the net salary starting with the brut salary
    brut -= brut * 0.20 
  end

  def job_contract_details(job_contract)
    name       = job_contract.job_contract_type.name
    start_date = job_contract.start_date.humanize
    end_date   =  job_contract.departure.humanize if job_contract.departure
    end_date ||=  job_contract.end_date.humanize if job_contract.end_date
    "#{ name } (#{ start_date } #{ '-' if end_date} #{ end_date })"
  end
end
 
