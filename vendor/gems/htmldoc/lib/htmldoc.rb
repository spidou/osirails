require "tempfile"

module PDF

  HTML = "html"
  HTMLSEP = "htmlsep"
  PDF = "pdf"
  PDF11 = "pdf11"
  PDF12 = "pdf12"
  PDF13 = "pdf13"
  PDF14 = "pdf14"
  PS = "ps"
  PS1 = "ps1"
  PS2 = "ps2"
  PS3 = "ps3"

  # Exception class representing an internal error in the HTMLDoc
  # class.
  class HTMLDocException < StandardError; end

  # The wrapper class around HTMLDOC, providing methods for setting
  # the options for the application and retriving the generate output
  # either as a file, diretory or string.
  class HTMLDoc

    @@basic_options = [:bodycolor, :bodyfont, :bodyimage, :bottom, :browserwidth,
                       :charset, :continuous, :cookies, :datadir, :effectduration,
                       :firstpage, :fontsize, :fontspacing, :footer, :gray, :header,
                       :headerfontfoot, :headfontsize, :headingfont, :landscape,
                       :left, :linkcolor, :linkstyle, :logoimage, :nup, :outdir,
                       :outfile, :owner_password, :pageduration, :pageeffect,
                       :pagelayout, :pagemode, :path, :permissions, :portrait,
                       :referer, :right, :size, :textcolor, :textfont, :titlefile,
                       :titleimage, :tocfooter, :tocheader, :toclevels, :toctitle,
                       :user_password, :webpage]

    @@extra_options = [:compression, :duplex, :embedfonts, :encryption, :jpeg,
                       :links, :localfiles, :numbered, :pscommands, :strict, :title,
                       :toc, :xrxcomments]

    @@all_options = @@basic_options + @@extra_options

    # The path to HTMLDOC in the system. E.g, <code>/usr/bin/html</code> or
    # <code>"C:\Program Files\HTMLDOC\HTMLDOC.exe"</code>.
    @@program_path = "htmldoc"

    # The last result from the generation of the output file(s). It's
    # a hash comprising three pairs:
    # <tt>bytes</tt>:: The number of bytes generated in the last request or <tt>nil</tt>
    # <tt>pages</tt>:: The number of pages generated in the last request or <tt>nil</tt>
    # <tt>output</tt>:: The raw output of the command
    attr_reader :result

    # The last error messages generate by the command. It's a hash
    # where they key represents the error number, and the value
    # represents the error message. If the error number is zero,
    # HTMLDOC was called with invalid parameters. Errors can happen
    # even if generation succeeds, for example, if an image can't be
    # found in the course of the generation.
    attr_reader :errors

    # Creates a blank HTMLDOC wrapper, using <tt>format</tt> to
    # indicate whether the output will be HTML, PDF or PS. The format
    # defaults to PDF, and can change using one of the module
    # contants.
    def initialize(format = PDF)
      @format = format
      @options = {}
      @pages = []
      @tempfiles = []
      reset
    end

    # Creates a blank HTMLDOC wrapper and passes it to a block. When
    # the block finishes running, the <tt>generate</tt> method is
    # automatically called. The result of <tt>generate</tt> is then
    # passed back to the application.
    def self.create(format = PDF, &block)
      pdf = HTMLDoc.new(format)
      if block_given?
        yield pdf
        pdf.generate
      end
    end

    # Gets the current path for the HTMLDOC executable. This is a
    # class method.
    def self.program_path
      @@program_path
    end

    # Sets the current path for the HTMLDOC executable. This is a
    # class method.
    def self.program_path=(value)
      @@program_path = value
    end

    # Sets an option for the wrapper. Only valid HTMLDOC options will
    # be accepted. The name of the option is a symbol, but the value
    # can be anything. Invalid options will throw an exception. To
    # unset an option, use <tt>nil</tt> as the value. Options with
    # negated counterparts, like <tt>:encryption</tt>, can be set
    # using false, :no or :none as the value.
    def set_option(option, value)
      if @@all_options.include?(option)
        if !value.nil?
          @options[option] = value
        else
          @options.delete(option)
        end
      else
        raise HTMLDocException.new("Invalid option #{option.to_s}")
      end
    end

    # Sets the header. It's the same as set_option :header, value.
    def header(value)
      set_option :header, value
    end

    # Sets the footer. It's the same as set_option :footer, value.
    def footer(value)
      set_option :footer, value
    end

    # Adds a page for generation. The page can be a URL beginning with
    # either <tt>http://</tt> or <tt>https://</tt>; a file, which will
    # be verified for existence; or any text.
    def add_page(page)
      if /^(http|https)/ =~ page
        type = :url
      elsif File.exists?(page)
        type = :file
      else
        type = :text
      end
      @pages << { :type => type, :value => page }
    end

    alias :<< :add_page

    # Invokes HTMLDOC and generates the output. If an output directory
    # or file is provided, the method will return <tt>true</tt> or
    # <tt>false</tt> to indicate completion. If no output directory or
    # file is provided, it will return a string representing the
    # entire output. Generate will raise a PDF::HTMLDocException if
    # the program path can't be found.
    def generate
      tempfile = nil
      unless @options[:outdir] || @options[:outfile]
        tempfile = Tempfile.new("htmldoc.temp")
        @options[:outfile] = tempfile.path
      end
      execute
      if @result[:bytes]
        if tempfile
          File.open(tempfile.path, "rb") { |f| f.read }
        else
          true
        end
      else
        false
      end
    ensure
      if tempfile
        tempfile.close
        @options[:outfile] = nil
      end
      @tempfiles.each { |t| t.close }
    end

    private

    def execute
      # Reset internal variables
      reset
      # Execute
      command = @@program_path + " " + get_command_options + " " + get_command_pages + " 2>&1"
      result = IO.popen(command) { |s| s.read }
      # Check whether the program really was executed
      if $?.exitstatus == 127
        raise HTMLDocException.new("Invalid program path: #{@@program_path}")
      else
        @result[:output] = result
        result.split("\n").each do |line|
          line.strip!
          case line
            when /^BYTES: (\d+)/
              @result[:bytes] = $1.to_i
            when /^PAGES: (\d+)/
              @result[:pages] = $1.to_i
            when /^ERROR: (.*)$/
              @errors[0] = $1.strip
            when /^ERR(\d+): (.*)$/
              @errors[$1.to_i] = $2.strip
          end
        end
      end
    end

    def reset
      @result = { :bytes => nil, :pages => nil, :output => nil }
      @errors = { }
    end

    def get_command_pages
      pages = @pages.collect do |page|
        case page[:type]
          when :file, :url
            page[:value]
          else
            t = Tempfile.new("htmldoc.temp")
            t.binmode
            t.write(page[:value])
            t.flush
            @tempfiles << t
            t.path
        end
      end
      pages.join(" ")
    end

    def get_command_options
      options = @options.dup.merge({ :format => @format })
      options = options.collect { |key, value| get_final_value(key, value) }
      options.sort.join(" ")
    end

    def get_final_value(option, value)
      option_name = "--" + option.to_s.gsub("_", "-")
      if value.kind_of?(TrueClass)
        option_name
      elsif value.kind_of?(Hash)
        items = value.collect { |name, contents| "#{name.to_s}=#{contents.to_s}" }
        option_name + " '" + items.sort.join(";") + "'"
      elsif @@basic_options.include?(option)
        option_name + " " + value.to_s
      else
        if [false, :no, :none].include?(value)
          option_name.sub("--", "--no-")
        else
          option_name + " " + value.to_s
        end
      end
    end

  end

end
