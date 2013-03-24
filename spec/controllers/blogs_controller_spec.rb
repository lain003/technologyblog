# coding: utf-8

require 'spec_helper'

describe BlogsController do
  fixtures :users,:blogs,:tags,:blog_tags

  describe "ログインした状態で" do
    before(:each) do
      @user = User.find(1)
      sign_in @user
    end

    describe "GET index" do
      it "親のuserクラスのインスタンスが設定されていること" do
        get :index, :user_id => 1
        assigns(:user).id.should == 1
      end

      it "updated_atの降順で結果が帰ってくること" do
        get :index, :user_id => 1, :page => 1
        assigns(:blogs).first.id.should == 3
      end

      it "全文検索が行われてる事" do
        get :index,:user_id => 1,:search=>{:word=>"ruby"}

        pending "indexがtestではうまくはれてない？"
      end

      it "タグで検索できること" do
        get :index,:user_id => 1,:search=>{:tag=>"test_tag1"}

        assigns(:blogs).first.title.should eq("fixtures_title1")
      end

      it "指定した日時のBlogが取得できること" do
        get :index,:user_id => 1,:search=>{:date=>"2011/5"}

        assigns(:blogs).size.should eq(2)
      end

      describe "カレンダーで" do
        it "各年月毎のBlogの件数が取得できること" do
          get :index,:user_id => 1

          blogsize_calendar = assigns(:blogsize_calendar)
          blogsize_calendar[2011][5].should eq(2)
          blogsize_calendar[2011][4].should eq(0)
        end

        it "別のユーザのBlogの分が紛れ込まない事" do
          @blog = User.find(2).blogs.new
          @blog.title = "user2_title"
          @blog.content = "user2_content"
          @blog.created_at = Time.local(2012, 1, 1, 23, 59, 59)
          @blog.updated_at = Time.local(2012, 1, 1, 23, 59, 59) 
          @blog.save
          
          get :index,:user_id => 1

          blogsize_calendar = assigns(:blogsize_calendar)
          blogsize_calendar[2012][1].should eq(0)
        end
      end

      it "Tagの一覧と、各Tagの件数をカウントしたhashが取得できること" do
        get :index,:user_id => 1

        tags_list = assigns(:tags_list)
        tags_list["test_tag1"].should eq(2)
        tags_list["test_tag2"].should eq(1)
      end

      it "Tagの一覧が、valueの値で降順になっていること" do
        get :index,:user_id => 1

        tags_list = assigns(:tags_list)
        
        before_value = tags_list.first.second
        tags_list.each do |tag|
          tag.second.should <= before_value
          before_value = tag.second
        end
      end
    end

    describe "POST import_create" do
      it "jsonファイルを受信して、それをもとにBlogモデルが作成されていること" do
        blog_file = File.new("spec/fixtures/blog.json")
        blog_json = JSON.parse(blog_file.read.kconv(Kconv::UTF8, Kconv::UTF8)).last
        upload_file = Rack::Test::UploadedFile.new("spec/fixtures/blog.json", "application/json")
        post :import_create, file:upload_file,user_id:1

        blog = Blog.last
        blog.title.should eq(blog_json["title"])
        blog.content.should eq(blog_json["content"])
        blog.tags[0].tag.should eq(blog_json["tags"][0])
        blog.tags[1].tag.should eq(blog_json["tags"][1])
      end
    end

    describe "GET export.json" do
      it "Blogsのデータ（タグも含む）がjson形式になって、帰ってくる事" do
        get :export,:format => :json,user_id:1

        response_json = JSON.parse(response.body)
        response_json[0]["title"].should eq("fixtures_title1")
        response_json[0]["tags"][0].should eq("test_tag1")
        response_json[0]["tags"][1].should eq("test_tag2")
        response_json[1]["title"].should eq("railsで全文検索")
        response_json[2]["title"].should eq("activerecordのsaveでTimestanpを更新しない")
      end
    end

    describe "GET edit" do
      it "問題なく動く事" do
        get :edit, user_id:1,id:1

        blog = assigns :blog
        blog.id.should eq(1)
      end
      
      it "Tagの一覧が取得できること" do
        get :edit, user_id:1,id:1
        
        tags = assigns :tags
        tags.size.should eq(Tag.all.size)
      end
    end
    
    describe "GET new" do
      it "Tagの一覧が取得できること" do
        get :new, user_id:1,id:1
        
        tags = assigns :tags
        tags.size.should eq(Tag.all.size)        
      end
    end

    describe "PUT update" do
      it "渡されてきたタグ文字列(例：'tag1,tag2')が、ちゃんとTagsモデルに変換されて保存されること" do
        put :update, user_id:1,id:1,:tags=>{tag:"update_tag1,update_tag2"}

        blog = assigns :blog
        blog.tags[0].tag.should eq("update_tag1")
        blog.tags[1].tag.should eq("update_tag2")
      end

      it "正しい遷移先に誘導されること" do
        put :update, user_id:1,id:1,:tags=>{tag:"update_tag1,update_tag2"}

        response.header["Location"].should eq("http://test.host/users/1/blogs/1")
      end
    end

    describe "POST createで" do
      it "渡されてきたタグ文字列(例：'tag1,tag2')が、ちゃんとTagsモデルに変換されて保存されること" do
        post :create, user_id:1,id:1,:tags=>{tag:"create_tag1,create_tag2"}

        blog = assigns :blog
        blog.tags[0].tag.should eq("create_tag1")
        blog.tags[1].tag.should eq("create_tag2")
      end
    end
  end

  describe "ブログの投稿者でないユーザがログインした状態で" do
    before(:each) do
      @user = User.find(2)
      sign_in @user
    end

    describe "GET indexに" do
      it "普通にアクセスできること" do
        get :index, :user_id => 1

        blogs = assigns :blogs
        blogs.first.title.should eq("activerecordのsaveでTimestanpを更新しない")
      end
    end

    describe "GET showに" do
      it "普通にアクセスできること" do
        get :show, :user_id => 1,:id => 1

        blog = assigns :blog
        blog.title.should eq("fixtures_title1")
      end
    end

    describe "GET editに" do
      it "HTTP STATUS が 302を返す事" do
        get :edit, user_id:1,id:1

        response.status.should eq(302)
      end
    end

    describe "POST createに" do
      it "HTTP STATUS が 302を返す事" do
        post :create, user_id:1,id:1,:tags=>{tag:"create_tag1,create_tag2"}

        response.status.should eq(302)
      end
    end

    describe "PUT update" do
      it "HTTP STATUS が 302を返す事" do
        put :update, user_id:1,id:1,:tags=>{tag:"update_tag1,update_tag2"}

        response.status.should eq(302)
      end
    end

    describe "POST import_create" do
      it "HTTP STATUS が 302を返す事" do
        blog_file = File.new("spec/fixtures/blog.json")
        blog_json = JSON.parse(blog_file.read.kconv(Kconv::UTF8, Kconv::UTF8)).last
        upload_file = Rack::Test::UploadedFile.new("spec/fixtures/blog.json", "application/json")
        post :import_create, file:upload_file,user_id:1

        response.status.should eq(302)
      end
    end
  end

  describe "ログインしてない状態で" do
    describe "GET indexに" do
      it "普通にアクセスできること" do
        get :index, :user_id => 1

        blogs = assigns :blogs
        blogs.first.title.should eq("activerecordのsaveでTimestanpを更新しない")
      end
    end

    describe "GET showに" do
      it "普通にアクセスできること" do
        get :show, :user_id => 1,:id => 1

        blog = assigns :blog
        blog.title.should eq("fixtures_title1")
      end
    end

    describe "POST createに" do
      it "HTTP STATUS が 302を返す事" do
        post :create, user_id:1,id:1,:tags=>{tag:"create_tag1,create_tag2"}

        response.status.should eq(302)
      end
    end

    describe "GET editに" do
      it "HTTP STATUS が 302を返す事" do
        get :edit, user_id:1,id:1

        response.status.should eq(302)
      end
    end

    describe "PUT update" do
      it "HTTP STATUS が 302を返す事" do
        put :update, user_id:1,id:1,:tags=>{tag:"update_tag1,update_tag2"}

        response.status.should eq(302)
      end
    end

    describe "POST import_create" do
      it "HTTP STATUS が 302を返す事" do
        blog_file = File.new("spec/fixtures/blog.json")
        blog_json = JSON.parse(blog_file.read.kconv(Kconv::UTF8, Kconv::UTF8)).last
        upload_file = Rack::Test::UploadedFile.new("spec/fixtures/blog.json", "application/json")
        post :import_create, file:upload_file,user_id:1

        response.status.should eq(302)
      end
    end
  end
end