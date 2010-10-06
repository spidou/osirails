#!/usr/bin/env ruby # this file has been inspired by 'rake-0.8.3/lib/rake/testtask.rb'

# Define a task library for running seed.

require 'rake'
require 'rake/tasklib'

module Rake
  
  # Create a task that runs a set of seeds.
  #
  # Example:
  #  
  #   Rake::SeedTask.new do |t|
  #     t.seed_files = FileList['db/*seeds.rb'].reverse
  #     t.verbose = true
  #   end
  #
  class SeedTask < TaskLib
    
    # Name of seed task. (default is :seed)
    attr_accessor :name
    
    # True if verbose seed output desired. (default is false)
    attr_accessor :verbose
    
    # Glob pattern to match seed files.
    attr_accessor :pattern
    
    # Explicitly define the list of seed files to be included in a
    # seed.  +list+ is expected to be an array of file names (a
    # FileList is acceptable).  If both +pattern+ and +seed_files+ are
    # used, then the list of seed files is the union of the two.
    def seed_files=(list)
      @seed_files = list
    end
    
    # Create a seeding task.
    def initialize(name=:seed)
      @name = name
      @pattern = nil
      @seed_files = nil
      @verbose = false
      yield self if block_given?
      define
    end
    
    # Create the tasks defined by this task lib.
    def define
      desc "Run seeds" + (@name==:seed ? "" : " for #{@name}")
      task @name do
        RakeFileUtils.verbose(@verbose) do
          ruby "\"#{rake_loader}\" " + file_list.collect { |fn| "\"#{fn}\"" }.join(' ')
        end
      end
      self
    end
    
    def file_list # :nodoc:
      result = []
      result += @seed_files.to_a if @seed_files
      result += FileList[ @pattern ].to_a if @pattern
      FileList[result].map{ |f| File.expand_path f }
    end
    
    def rake_loader # :nodoc:
      find_file('lib/rake/rake_seed_loader') or
        fail "unable to find rake seed loader"
    end
    
    def find_file(fn) # :nodoc:
      $LOAD_PATH.each do |path|
        file_path = File.join(path, "#{fn}.rb")
        return file_path if File.exist? file_path
      end
      nil
    end
    
  end
end
