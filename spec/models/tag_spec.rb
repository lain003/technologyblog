# coding: utf-8

require 'spec_helper'

describe Tag do
  describe "self.factory_tag" do
    fixtures :users,:blogs,:tags,:blog_tags
    
    it "渡されてきた文字列をもとに、新しいTagを生成してDBに保存する。そして生成したTagを返してくる事" do
      before_tagdb_size = Tag.all.size 
      
      tag = Tag.factory_tag("unique_tagname")
      
      Tag.all.size.should eq(before_tagdb_size+1)
      tag.tag.should eq("unique_tagname")
    end
    
    it "既存のTagと同じ文字列が渡されてきたときに、新しいTagを作らずに既存のTagを使い回している事。" do
      existing_tag = Tag.first
      
      tag = Tag.factory_tag(existing_tag.tag)
      
      tag.should eq(existing_tag)
    end
  end
  
  describe "save" do
    it "大文字を小文字に変換して保存すること" do
      tag = Tag.new
      tag.tag = "Ruby"
      tag.save
      
      Tag.last.tag.should eq("ruby") 
    end
  end
end
