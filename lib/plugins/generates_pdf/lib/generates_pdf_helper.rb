module GeneratesPdfHelper
  require 'fop'

  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :fop
    end
  end

  def render_with_fop(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:pdf)
      begin
        make_and_send_pdf(options.delete(:pdf), options)
      rescue
        error_access_page(404)
      end
    else
      render_without_fop(options, *args, &block)
    end
  end

  private
    def make_pdf(options = {})
      f = FOP.new
      f.pdf_from_xml_and_xsl(render_to_string(:template => options[:template], :layout => false), options[:xsl])
    end

    def make_and_send_pdf(pdf_name, options = {})
      file = make_pdf(options)
      send_data(
        File.read(file),
        :filename => pdf_name + '.pdf',
        :type => 'application/pdf'
      )
      File.delete(file)
    end
end
