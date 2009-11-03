# Apache FOP Ruby interface
# http://xmlgraphics.apache.org/fop/

require 'logger'
require 'digest/md5'

class Fop
  attr_accessor :exe_path, :log_file, :logger

  def initialize
    @exe_path = `which fop`.chomp
    raise PdfGeneratorError, "command not found: '#{@exe_path}'. It seems FOP is missing, please install it and retry (http://osirails.spidou.com/wiki/doku.php?id=osirails:developer:installation_prerequisites#apache_fop_for_pdf_generation)" unless File.exists?(@exe_path)
    @log_file = "#{RAILS_ROOT}/log/fop.log"
    @logger   = RAILS_DEFAULT_LOGGER
  end

  def pdf_from_xml_and_xsl(xml_rendering, xsl, file_name, pdf_path = nil)
    if pdf_path.nil?
      is_temporary_pdf = true
      pdf_path = "tmp/#{Digest::MD5.hexdigest(Time.now.to_i.to_s)}.pdf"
    end
    
    return { :pdf_path => pdf_path, :is_temporary_pdf => is_temporary_pdf } if File.exist?(pdf_path)
    
    xsl_path = "public/fo/style/#{xsl}.xsl"
  
    path = @exe_path
    
    logger.info "\n\n-- FO generation --"
    
    tmp_xml = "#{RAILS_ROOT}/public/fo/tmp/#{Digest::MD5.hexdigest(Time.now.to_i.to_s)}.xml"
    
    `mkdir #{RAILS_ROOT}/public/fo/tmp -p`
    f = File.open(tmp_xml, 'w')
    
    f.write(xml_rendering)
    f.close
    
    logger.info tmp_xml
    logger.info "\n\n-- FOP command --"
    
    `mkdir #{RAILS_ROOT}/#{File.dirname(pdf_path)} -p`
    command = "#{path} -q -xml #{tmp_xml} -xsl #{xsl_path} -pdf #{pdf_path}"

    logger.info command
    
    `#{command}`
    File.delete(tmp_xml)
    return { :pdf_path => pdf_path, :is_temporary_pdf => is_temporary_pdf }
  end
end
