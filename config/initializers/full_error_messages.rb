class ActiveRecord::Errors
  def full_messages
    full_messages = []

    @errors.each_key do |attr|
      @errors[attr].each do |msg|
        next if msg.nil?

        if attr == "base" || msg =~ /^[[:upper:]]/
          full_messages << msg
        else
          full_messages << @base.class.human_attribute_name(attr) + " " + msg
        end
      end
    end
    full_messages
  end
end
