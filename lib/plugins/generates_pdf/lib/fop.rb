# Apache FOP Ruby interface
# http://xmlgraphics.apache.org/fop/

require 'logger'
require 'digest/md5'

class FOP
  attr_accessor :exe_path, :log_file, :logger

  def initialize
    @exe_path = `which fop`.chomp
    @log_file = "#{RAILS_ROOT}/log/fop.log"
    @logger   = RAILS_DEFAULT_LOGGER
  end

  def pdf_from_xml_and_xsl(xml_rendering,xsl)    
    xsl_path = "#{RAILS_ROOT}/public/fo/style/#{xsl}.xsl"
  
    path = @exe_path
    
    logger.info "\n\n-- FO generation --"    
    
    tmp_xml = "#{RAILS_ROOT}/public/fo/tmp/#{Digest::MD5.hexdigest(Time.now.to_i.to_s)}.xml"
    
    File.new(tmp_xml,'w')
    f = File.open(tmp_xml,'w')
    
    f.write(xml_rendering)
    f.close
    
    logger.info tmp_xml
    logger.info "\n\n-- FOP command --"
    
    tmp_pdf = "tmp/#{Digest::MD5.hexdigest(Time.now.to_i.to_s)}.pdf"
    path = "#{path} -xml #{tmp_xml} -xsl #{xsl_path} -pdf #{tmp_pdf}"

    logger.info path
    logger.info ''
    
    `#{path}`
    File.delete(tmp_xml)
    tmp_pdf
  end
end
