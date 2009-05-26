require File.dirname(__FILE__) + '/test_helper.rb'

class BasicTest < Test::Unit::TestCase

  def test_options
    all_options = PDF::HTMLDoc.class_eval do
      class_variable_get(:@@all_options)
    end
    all_options.each do |option|
      pdf = PDF::HTMLDoc.new
      pdf.set_option option, :default
      assert_equal :default, pdf.instance_variable_get(:@options)[option]
      assert_equal 1, pdf.instance_variable_get(:@options).size
      pdf.set_option option, nil
      assert_equal 0, pdf.instance_variable_get(:@options).size
    end
    pdf = PDF::HTMLDoc.new
    i = 0
    all_options.each do |option|
      pdf.set_option option, i
      assert_equal i, pdf.instance_variable_get(:@options)[option]
      assert_equal i + 1, pdf.instance_variable_get(:@options).size
      i += 1
    end
    assert_raise(PDF::HTMLDocException) { pdf.set_option :test, :value }
    assert_raise(PDF::HTMLDocException) { pdf.set_option "test", "value" }
  end

  def test_header
    pdf = PDF::HTMLDoc.new
    pdf.header ".t."
    assert_equal ".t.", pdf.instance_variable_get(:@options)[:header]
    assert_equal 1, pdf.instance_variable_get(:@options).size
  end

  def test_footer
    pdf = PDF::HTMLDoc.new
    pdf.footer ".t."
    assert_equal ".t.", pdf.instance_variable_get(:@options)[:footer]
    assert_equal 1, pdf.instance_variable_get(:@options).size
  end

  def test_get_final_value
    # Those tests are not exhaustive, but will ensure a reasonable
    # level of functionality
    pdf = PDF::HTMLDoc.new
    tests = [["--webpage", :webpage, true],
             ["--no-encryption", :encryption, :none],
             ["--no-encryption", :encryption, :no],
             ["--no-encryption", :encryption, false],
             ["--encryption", :encryption, true],
             ["--no-encryption", :encryption, :none],
             ["--no-jpeg", :jpeg, :no],
             ["--jpeg 80", :jpeg, 80],
             ["--bodycolor black", :bodycolor, :black],
             ["--left 12in", :left, "12in"],
             ["--cookies 'name=value;other=test'", :cookies, { :name => "value", :other => "test" }]]
    tests.each do |test|
      assert_equal test.first, pdf.send(:get_final_value, *test[1,2])
    end
  end

  def test_get_command_options
    # Those tests are not exhaustive, but should ensure a reasonable
    # level of functionality.
    pdf = PDF::HTMLDoc.new
    tests = [["--webpage", :webpage, true],
             ["--no-encryption", :encryption, :none],
             ["--jpeg 80", :jpeg, 80],
             ["--bodycolor black", :bodycolor, :black],
             ["--left 12in", :left, "12in"],
             ["--cookies 'name=value;other=test'", :cookies, { :name => "value", :other => "test" }]]
    tests.each do |test|
      pdf.send(:set_option, *test[1,2])
    end
    command_options = tests.collect { |test| test.first }
    command_options = (command_options + ["--format " + PDF::PDF]).sort.join(" ")
    assert_equal command_options, pdf.send(:get_command_options)
  end

  def test_get_command_pages
    # Those tests are not exhaustive, but should ensure a reasonable
    # level of functionality.
    pdf = PDF::HTMLDoc.new
    tempfile = Tempfile.new("htmldoc.test")
    pages = ["http://example.org/", tempfile.path, "Test"]
    pages.each do |page|
      pdf << page
    end
    command_pages = pdf.send(:get_command_pages)
    pages[2] = pdf.instance_variable_get(:@tempfiles)[0].path
    assert_equal pages.join(" "), command_pages
  ensure
    tempfiles = pdf.instance_variable_get(:@tempfiles)
    tempfiles.each { |t| t.close }
  end

end
