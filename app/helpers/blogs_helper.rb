module BlogsHelper
  def date_to_s(date)
    date.strftime("%Y-%m-%d")
  end

  def tags_to_s(tags)
    tags_s = ""
    tags.each do |tag|
      tags_s += tag.tag + ","
    end
    tags_s[0..-2]
  end
end
