require 'matchers/act_as_watcher_matcher'

module ActsAsWatcher
  module Shoulda
    include Matchers
    def should_act_as_watcher
      klass = self.name.gsub(/Test$/, '').constantize
      
      matcher = act_as_watcher
      should matcher.description do
        assert_accepts(matcher, klass)
      end
    end
  end
end

class Test::Unit::TestCase #:nodoc:
  extend ActsAsWatcher::Shoulda
end
