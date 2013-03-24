class Array
  def convert_to_string
    return_s = ""
    self.each do |s|
      return_s += s+","
    end
    return_s[0..-2]
  end
end

class String
  def convert_to_array
    self.split(/\s*,\s*/)
  end
end