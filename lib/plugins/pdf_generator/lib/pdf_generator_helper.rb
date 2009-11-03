module PdfGeneratorHelper
  require 'fop'

  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :fop
    end
  end

  def render_with_fop(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:pdf)
      begin
        make_and_send_pdf(options)
      rescue
        error_access_page(404)
      end
    else
      render_without_fop(options, *args, &block)
    end
  end

  private
    def make_pdf(options = {})
      f = Fop.new
      f.pdf_from_xml_and_xsl(render_to_string(:template => options[:template], :layout => false), options[:xsl], options[:pdf], options[:path])
    end

    def make_and_send_pdf(options = {})
      result = make_pdf(options)
      send_data(
        File.read(result[:pdf_path]),
        :filename => options[:pdf] + '.pdf',
        :type => 'application/pdf'
      )
      File.delete(result[:pdf_path]) if result[:is_temporary_pdf]
    end
end
