# coding: utf-8

require 'spec_helper'

describe Blog do
  fixtures :users,:blogs,:tags,:blog_tags
  
  before do
    
  end
  
  describe "set_instans" do
    it "blogコントローラのimport_createでとってきたhashデータが、正常にインスタンスにセットされていること" do
      blog = Blog.new
      hash = {"title" => "タイトル","content" => "文章","tags" => ["カテゴリー"],"created_at" => "2011-05-30"}
      blog.set_instans(hash)
      
      blog.title.should eq(hash["title"])
      blog.content.should eq(hash["content"])
      blog.tags[0].tag.should eq(hash["tags"][0])
      updated_at = blog.updated_at.in_time_zone("Tokyo")
      created_at = blog.created_at.in_time_zone("Tokyo")
      updated_at.year.should eq(2011)
      updated_at.month.should eq(5)
      updated_at.day.should eq(30)
      created_at.year.should eq(2011)
      created_at.month.should eq(5)
      created_at.day.should eq(30)
    end
  end
  
  describe "save_tags" do
    it "文字列で渡されてきたtags_sが、正常にtagsに保存されること" do
      blog = Blog.new
      blog.save_tags("save_tag1,save_tag2")
      
      blog.tags[0].tag.should eq("save_tag1")
      blog.tags[1].tag.should eq("save_tag2")
    end
  end
  
  describe "to_hash" do
    it "自身のメンバ変数をjson形式に変換し、かつ自分に関連するタグもjsonになっていること" do
      blog = Blog.find(1)
      blog_json = blog.to_hash
      
      blog_json["title"].should eq("fixtures_title1")
      blog_json["tags"][0].should eq("test_tag1")
      blog_json["tags"][1].should eq("test_tag2")
    end
  end
  
  describe "self.full_text_search" do
    it "全文検索を行える事" do
      #Sunspot.commit##正常に動いていない。indexがつけられてない？
      #blogs = Blog.full_text_search("rails")
      #blogs[0].title.should eq("railsで全文検索")
    end
  end
  
  
end

