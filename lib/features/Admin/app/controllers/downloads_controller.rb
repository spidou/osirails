class DownloadsController < ApplicationController
  
  def show
    @file = Document.find(params[:id])
    
    send_file(params[:file]) 
  end
end
