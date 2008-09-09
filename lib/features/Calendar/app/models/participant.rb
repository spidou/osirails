class Participant < ActiveRecord::Base
  # Relationships
  belongs_to :event
  
  def self.parse(p)
    p = p.split(/[<>]/)
    email = nil
    p.each do |v|
      email = v unless v.grep(/^(\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,5})+)*$/).empty?
    end
    name = p[0...(p.index(email) || p.size)].join('')
    {:name => name, :email => email}
  end
end
