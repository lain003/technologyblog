module ApplicationHelper
  include TweetButton
  def breadcrumb
    lam = lambda do |xml,url, title|
      xml.li(:itemscope => nil,:itemtype => "http://data-vocabulary.org/Breadcrumb") do
        xml.a(:href => url,:itemprop => "url") do
          xml.span(:itemprop => "title",:class => "divider") do
            xml.text(title)
          end
        end
      end
    end

    breadcrumb_html = Nokogiri::XML::Builder.new do |xml|
      xml.ul(:class => "breadcrumb") do
        lam.call(xml,root_path,"TOP")
        if params[:controller] == "blogs"
          xml.text(" > ")
          lam.call(xml,user_blogs_path(@user),@user.name)
          if @blog
            xml.text(" > ")
            lam.call(xml,user_blog_path(@user,@blog),@blog.title)
          end
        end
      end
    end

    return breadcrumb_html.doc.root.to_s.html_safe
  end

  def markdown(text)
    markdown = Redcarpet::Markdown.new(MarkdownRenderer.new(:hard_wrap => true), :autolink => true,:fenced_code_blocks => true)
    syntax_highlighter(markdown.render(text)).html_safe
  end

  def remove_markdown(text)
    syntax_highlighter(Redcarpet::Markdown.new(MarkdownRenderer).render(text),true).html_safe
  end

  private

  def syntax_highlighter(html,remove = false)
    doc = Nokogiri::HTML.fragment(html)
    doc.xpath("pre").each do |pre|
      lang = pre.children[0]["class"]
      if lang
        pre.replace Albino.colorize(pre.text.rstrip, lang)
      end
    end

    if remove then
    doc.content
    else
    doc.to_s
    end
  end
end

class MarkdownRenderer < Redcarpet::Render::HTML
  def link(link, title, alt_text)
    "<a target=\"_blank\" href=\"#{link}\">#{alt_text}</a>"
  end

  def autolink(link, link_type)
    "<a target=\"_blank\" href=\"#{link}\">#{link}</a>"
  end
end
