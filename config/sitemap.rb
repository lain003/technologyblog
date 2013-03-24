# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://technologyblog.lain003.info/"

SitemapGenerator::Sitemap.create do
  add "/users",:changefreq => 'weekly',:priority => 0.5
  Blog.all.each do |blog|
    add user_blog_path(blog.user,blog),:changefreq => 'weekly',:priority => 0.7,:lastmod => blog.updated_at
  end
end
