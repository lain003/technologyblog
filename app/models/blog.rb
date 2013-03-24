class Blog < ActiveRecord::Base
  attr_accessible :content, :title

  belongs_to :user
  has_many :blog_tags
  has_many :tags,:through => :blog_tags

  searchable do
    text :title, :boost => 5, :more_like_this => true
    text :content,:more_like_this => true
    date :updated_at
    integer :user_id

    text :tags,:more_like_this => true do
      self.tags.map(&:tag)
    end
  end

  def set_instans(hash)
    self.title = hash["title"]
    self.content = hash["content"]
    
    hash["tags"].each do |tag_s|
      tag = Tag.factory_tag(tag_s)
      self.tags << tag
    end

    self.created_at = DateTime.strptime(hash["created_at"],"%Y-%m-%d")
    self.updated_at = DateTime.strptime(hash["created_at"],"%Y-%m-%d")
  end

  def save_tags(tags_s)
    tags_s.convert_to_array.each do |tag_s|
      tag = Tag.factory_tag(tag_s)
      self.tags << tag
    end
  end
  
  def more_like_this
    results = Sunspot.more_like_this(self) do
      fields :content,:tags,:title
      minimum_document_frequency 30
    end
    return results.results
  end

  def self.full_text_search(user_id,search_word,page = 1)
    result = Blog.search do
      fulltext search_word
      with(:user_id, user_id)
      paginate :page => page, :per_page => Kaminari.config.config[:default_per_page]
      order_by :updated_at, :desc
    end
    @blogs = result.results
  end
  
  def to_hash
    blog_json = ActiveSupport::JSON.decode(self.to_json)
    tags = Array.new
    self.tags.each do |tag|
      tags << tag.tag
    end
    blog_json["tags"] = tags
     
    return blog_json
  end
end
