# Apache FOP Ruby interface
# http://xmlgraphics.apache.org/fop/

require 'logger'
require 'digest/md5'

class Fop
  cattr_accessor :exe_path, :log_file, :logger

  @@exe_path   = `which fop`.chomp
  @@log_file   = "log/fop.log"
  @@logger     = RAILS_DEFAULT_LOGGER
    
  def self.check_dependencies
    raise PdfGeneratorError, "command not found: '#{@@exe_path}' for user '#{`whoami`}'. It seems FOP is missing, please install it and retry (http://osirails.spidou.com/wiki/doku.php?id=osirails:developer:installation_prerequisites#apache_fop_for_pdf_generation)" unless File.exists?(@@exe_path)
  end

  def self.pdf_from_xml_and_xsl(xml_rendering, xsl_path, file_name, pdf_path, is_temporary_pdf)
    return { :pdf_path => pdf_path, :is_temporary_pdf => is_temporary_pdf } if File.exist?(pdf_path)
  
    self.format_from_xml_and_xsl(xml_rendering, xsl_path,pdf_path)
    
    return { :pdf_path => pdf_path, :is_temporary_pdf => is_temporary_pdf }
  end
  
  def self.area_tree_from_xml_and_xsl(xml_rendering, xsl_path, area_tree_path)
    self.format_from_xml_and_xsl(xml_rendering, xsl_path, area_tree_path)
    
    return area_tree_path
  end
  
  private
    def self.format_from_xml_and_xsl(xml_rendering, xsl_path, output_path)
      return unless [".at",".pdf"].include?(File.extname(output_path))
      
      if File.extname(output_path) == ".at"
        format = "Area Tree"
        format_option = "at"
      elsif File.extname(output_path) == ".pdf"
        format = "PDF"
        format_option = "pdf"
      end
      
      path = @@exe_path
    
      logger.info "\n\n-- XML generation --"
      
      tmp_xml = "public/fo/tmp/#{Digest::MD5.hexdigest(Time.now.to_i.to_s)}.xml"
      
      `mkdir public/fo/tmp -p`
      f = File.open(tmp_xml, 'w')
      
      f.write(xml_rendering)
      f.close
      
      logger.info tmp_xml
      logger.info "\n\n-- #{format} generation with FOP --"
      
      `mkdir #{File.dirname(output_path)} -p`
      
      format_generation = "#{path} -q -xml #{tmp_xml} -xsl #{xsl_path} -#{format_option} #{output_path}"

      logger.info format_generation
      
      `#{format_generation}`
      
      File.delete(tmp_xml)
    end
end
