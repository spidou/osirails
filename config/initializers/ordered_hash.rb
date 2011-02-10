# this file can be deleted once we use ruby1.9
module ActiveSupport
  class OrderedHash
    include CoreExtensions::Hash::Keys
    
    def merge!(other_hash) # this method is a backport compatibility and can be removed once we update to rails 2.3.2 or later
      other_hash.each {|k,v| self[k] = v }
      self
    end
  end
end
