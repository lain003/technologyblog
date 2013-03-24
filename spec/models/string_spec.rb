# coding: utf-8

require 'spec_helper'

describe String do
  it "タグデータのStringデータをArrayに変換できること" do
      tags_s = "ruby,rails"
      tags_array = tags_s.convert_to_array
      tags_array[1].should == "rails"
  end
end