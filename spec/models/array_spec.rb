# coding: utf-8

require 'spec_helper'

describe Array do
  it "ArrayデータをStringに変換できること" do
      tags = ["tag1","tag2"]
      tags_s = tags.convert_to_string
      tags_s.should == "tag1,tag2"
  end
end