require File.dirname(__FILE__) + '/test_helper.rb'

class GenerationTest < Test::Unit::TestCase

  def setup
    # If you are using a different program path, you should configure
    # it here.
    @program_path = PDF::HTMLDoc.program_path
  end

  def test_program_path
    data = IO.popen(@program_path + " --version 2>&1") { |s| s.read }
    assert_equal 0, $?.exitstatus
    assert_match(/^1.((8.2\d)|9-current)/, data)
  end

  def test_generation
    # Those tests are not exhaustive, but will ensure a reasonable
    # level of functionality. Output to directories is not tested for
    # now.
    basic_test(PDF::HTML)
    basic_test(PDF::PS)
    basic_test(PDF::PDF)
  end

  def test_generation_results
    pdf = PDF::HTMLDoc.new
    pdf.set_option :webpage, true
    pdf.set_option :toc, false
    pdf << "<h1>Random title</h1>"
    assert_kind_of String, pdf.generate
    assert_not_nil pdf.result[:bytes]
    assert_not_nil pdf.result[:pages]
    assert_equal 0, pdf.errors.size
    assert_equal 1, pdf.result[:pages]
  end

  def test_invalid_program_path
    PDF::HTMLDoc.program_path = @program_path + "-non-existing-path"
    assert_raise(PDF::HTMLDocException) { PDF::HTMLDoc.new.generate }
  ensure
    PDF::HTMLDoc.program_path = @program_path
  end

  def test_generation_errors
    # This test can fail if the collapsing wavefront of the Internet
    # somehow becomes random.
    # Test invalid input
    pdf = PDF::HTMLDoc.new
    pdf.set_option :outfile, "test.pdf"
    pdf << "http://#{simple_uid(".com")}:12345/#{simple_uid(".html")}"
    pdf.generate
    assert_not_equal 0, pdf.errors.size
    assert_nil pdf.result[:bytes]
    assert_nil pdf.result[:pages]
    # Test an invalid option
    pdf = PDF::HTMLDoc.new
    pdf.set_option :outfile, "test.pdf"
    pdf << "http://#{simple_uid(".com")}:12345/#{simple_uid(".html")} --non-existing-option"
    pdf.generate
    assert_not_equal 0, pdf.errors.size
    assert_nil pdf.result[:bytes]
    assert_nil pdf.result[:pages]
  end

  private

  def basic_test(format)
    # Temporary files
    path1, path2 = (1..2).collect { |i| Dir.tmpdir + "/#{i}.#{format}" }
    # Create a temporary file for the duration of the test
    Tempfile.open("htmldoc.test") do |tempfile|
      # Load the temporary file with some test datas
      page = "<h1>Page 1</h1><p>Test.</p><h1>Page 2</h1><p>Test.</p>"
      tempfile.binmode
      tempfile.write(page)
      tempfile.flush
      # Simple format test
      pdf = PDF::HTMLDoc.new(format)
      pdf.set_option :outfile, path1
      pdf.add_page tempfile.path
      assert_equal true, pdf.generate
      assert_equal pdf.result[:output], execute_htmldoc(path2, tempfile.path, "--format #{format}")
      # Delete temporary files
      File.delete(path1) if File.exists?(path1)
      File.delete(path2) if File.exists?(path2)
      # Simple webpag format test
      pdf = PDF::HTMLDoc.new(format)
      pdf.set_option :outfile, path1
      pdf.set_option :webpage, true
      pdf.add_page tempfile.path
      assert_equal true, pdf.generate
      assert_equal pdf.result[:output], execute_htmldoc(path2, tempfile.path, "--webpage --format #{format}")
      # Delete temporary files
      File.delete(path1) if File.exists?(path1)
      File.delete(path2) if File.exists?(path2)
      # Simple options test
      pdf = PDF::HTMLDoc.new(format)
      pdf.set_option :outfile, path1
      pdf.set_option :bodycolor, :black
      pdf.add_page tempfile.path
      assert_equal true, pdf.generate
      assert_equal pdf.result[:output], execute_htmldoc(path2, tempfile.path, "--bodycolor black --format #{format}")
      # Delete temporary files
      File.delete(path1) if File.exists?(path1)
      File.delete(path2) if File.exists?(path2)
      # Free text generate test
      pdf = PDF::HTMLDoc.new(format)
      pdf.add_page page
      pdf.generate
      assert_equal pdf.result[:output], execute_htmldoc(path2, tempfile.path, "--format #{format}")
      # Delete temporary files
      File.delete(path2) if File.exists?(path2)
      # Inline generation test
      result = PDF::HTMLDoc.create(format) do |p|
        p.set_option :outfile, path1
        p.set_option :bodycolor, :black
        p.add_page tempfile.path
      end
      assert_equal true, result
    end
  end

  def execute_htmldoc(output, input, options)
    IO.popen("#{@program_path} #{options} -f #{output} #{input} 2>&1") { |s| s.read }
  end

  def simple_uid(extension)
    chars = ('A'..'Z').to_a + ('0'..'9').to_a
    (1..100).inject("") { |r, i| r + chars[rand(chars.length)] }
  end

end

#  LocalWords:  HTMLDOC
