class Tag < ActiveRecord::Base
  attr_accessible :tag
  
  has_many :blog_tags
  has_many :blogs,:through => :blog_tags
  
  searchable do
    text :tag
  end
  
  before_save :beforesave
  
  def beforesave
    self.tag = self.tag.downcase
  end
  
  def self.factory_tag(tag_word)
    if !(tag = Tag.search_unique_tag(tag_word))
      tag = Tag.new
      tag.tag = tag_word
      tag.save
    end  
    
    return tag
  end
  
  private
  def self.search_unique_tag(search_tag)
    Tag.all.each do |each_tag|
      if each_tag.tag == search_tag.downcase
        return each_tag
      end 
    end
    return nil
  end
end
