class BlogTag < ActiveRecord::Base
  attr_accessible :blog_id, :tag_id
  
  belongs_to :tag
  belongs_to :blog
end
