class JobContractsController < ApplicationController

# GET /employees/1/edit
  def edit
    @job_contract = JobContract.find(params[:id])
  end

end
