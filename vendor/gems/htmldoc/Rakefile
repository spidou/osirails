require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
require 'hoe'

include FileUtils
require File.join(File.dirname(__FILE__), 'lib', 'htmldoc', 'version')

AUTHOR = "Ronaldo M. Ferraz"
EMAIL = "ronaldo@reflectivesurface.com"
DESCRIPTION = "A wrapper around HTMLDOC, a PDF generation utility"
GEM_NAME = "htmldoc"
RUBYFORGE_PROJECT = "htmldoc"
HOMEPATH = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"

NAME = "HTMLDOC"
REV = File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
VERS = ENV['VERSION'] || (PDF::HTMLDOC::VERSION::STRING + (REV ? ".#{REV}" : ""))
                          CLEAN.include ['**/.*.sw?', '*.gem', '.config']
RDOC_OPTS = ['--quiet', '--title', "htmldoc documentation",
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README",
    "--inline-source"]

class Hoe
  def extra_deps 
    @extra_deps.reject { |x| Array(x).first == 'hoe' } 
  end 
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
hoe = Hoe.new(GEM_NAME, VERS) do |p|

  p.author = AUTHOR 
  p.email = EMAIL
  p.summary = DESCRIPTION
  p.url = HOMEPATH
  p.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  p.test_globs = ["test/**/*_test.rb"]
  p.clean_globs = CLEAN  #An array of file patterns to delete on clean.
  p.description = p.paragraphs_of('README.txt', 1..1).join("\n\n")
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")

  #p.extra_deps     - An array of rubygem dependencies.
  #p.spec_extras    - A hash of extra values to set in the gemspec.
end
