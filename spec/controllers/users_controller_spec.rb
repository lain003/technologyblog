# coding: utf-8
require 'spec_helper'

describe UsersController do
  fixtures :users
  describe "ログインした状態で" do
    before(:each) do
      @user = User.find(1)
      sign_in @user
    end

    describe "GET indexで" do
      it "普通にユーザの一覧を取得できること" do
        get :index

        users = assigns :users
        users.first.name.should eq("test_name")
      end

      it ".jsonでアクセスしてもデータは帰ってこないこと" do
        get :index,:format => "json"

        response.status.should eq(406)
      end
    end
    
    describe "Delete destroyで" do
      it "子であるblogも削除されていること" do
        delete :destroy,:id => 1
       
        Blog.where(:user_id => 1).size.should eq(0)
      end
      
      it "別のユーザを消せない事" do
        delete :destroy,:id => 2
       
        response.status.should eq(302)
      end
    end
  end
  
  describe "ログインしてない状態で" do
    describe "GET indexで" do
      it "普通にユーザの一覧を取得できること" do
        get :index

        users = assigns :users
        users.first.name.should eq("test_name")
      end
    end
    
    describe "Delete destroyで" do
      it "アクセスできないこと" do
        delete :destroy,:id => 1
       
        response.status.should eq(302)
      end
    end
  end
end