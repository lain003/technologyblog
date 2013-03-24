require 'json'
require 'kconv'

class BlogsController < ApplicationController
  before_filter :find_user
  before_filter :set_iphone_format
  before_filter :find_tags,:only => [:new,:edit]
  layout :set_layout
  load_and_authorize_resource
  
  # GET /blogs
  # GET /blogs.json
  def index
    if search_word = (params[:search] || {})[:word]
      @blogs = Blog.full_text_search(@user.id,search_word,params[:page])
    elsif search_tag = (params[:search] || {})[:tag]
      @blogs = []
      @user.blogs.each do |blog|
        @blogs << blog if blog.tags.find(:first,:conditions => "tag = '#{search_tag}'")
      end
      @blogs = Kaminari.paginate_array(@blogs).page(params[:page])
    elsif search_date = (params[:search] || {})[:date]
      date = DateTime.strptime(search_date+"/1","%Y/%m/%d")
      @blogs = Blog.where{(created_at >= date) & (created_at < (date >> 1))}.page params[:page]
    else
      @blogs = @user.blogs.order("updated_at DESC").page params[:page]
    end
    @blogsize_calendar = create_blogs_size_every_month
    @tags_list = craete_tag_list
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @blogs}
    end
  end

  # GET /blogs/1
  # GET /blogs/1.json
  def show
    #@blog.more_like_this
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /blogs/new
  # GET /blogs/new.json
  def new
    @blog = @user.blogs.build
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /blogs/1/edit
  def edit
  end

  # POST /blogs
  # POST /blogs.json
  def create
    @blog = @user.blogs.build(params[:blog])
    @blog.save_tags(params[:tags][:tag])
    respond_to do |format|
      if @blog.save
        format.html { redirect_to user_blog_path(params[:user_id],@blog), notice: 'Blog was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /blogs/1
  # PUT /blogs/1.json
  def update
    @blog.tags.delete_all
    @blog.save_tags(params[:tags][:tag])

    respond_to do |format|
      if @blog.update_attributes(params[:blog])
        format.html{ redirect_to(user_blog_path(@user,@blog), :notice => 'Invoice was successfully updated.') }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /blogs/1
  # DELETE /blogs/1.json
  def destroy
    @blog.destroy

    respond_to do |format|
      format.html { redirect_to user_blogs_path(params[:user_id]) }
    end
  end

  def import_create
    json_array = JSON.parse(params[:file].read.kconv(Kconv::UTF8, Kconv::UTF8))

    Blog.record_timestamps = false
    json_array.each do |json_hash|
      blog = @user.blogs.build
      blog.set_instans(json_hash)
      blog.save
    end
    Blog.record_timestamps = true

    respond_to do |format|
      format.html { redirect_to user_blogs_path(@user)}
    end
  end

  def import_new
    respond_to do |format|
      format.html
    end
  end
  
  def export
    blogs = @user.blogs
    
    blogs_json = Array.new
    blogs.each do |blog|
      blogs_json << blog.to_hash
    end
    
    respond_to do |format|
      format.json {render json: blogs_json}
    end
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end
  
  def find_tags
    @tags = Tag.all
  end
  
  def set_iphone_format
    if iphone_request? && request.format == "text/html"
      request.format = :iphone
    end
  end
  
  def set_layout
    iphone_request? ? "iphone" : "application"
  end
  
  def iphone_request?
    request.user_agent =~ /(Mobile.+Safari)/
  end
  
  def current_ability
    if current_user
      if current_user.id == @user.id
        def current_user.admin?
          true
        end
      end
    end
    @current_ability ||= Ability.new(current_user)
  end
  
  #return hash[year][month] = blogs.size
  def create_blogs_size_every_month
    calender = Hash.new
    
    first_blog = @user.blogs.order("created_at ASC").first
    if !first_blog
      return calender
    end
    
    (first_blog.created_at.year..Date.today.year).each do |year|
      calender[year] = Hash.new
      (1..12).each do |month|
        date = Date::new(year,month,1)
        calender[year][month] = @user.blogs.where{(created_at >= date) & (created_at < date >> 1)}.size
      end
    end
    
    return calender
  end
  
  #return hash[tag.tag] = tag_count
  def craete_tag_list
    tags_list = Hash.new
    @user.blogs.each do |blog| 
      blog.tags.each do |tag|
        if tags_list.key?(tag.tag)
          tags_list[tag.tag] += 1
        else
          tags_list[tag.tag] = 1
        end
      end 
    end

    sort_tags_list = Hash.new
    tags_list.sort_by{|key,val| -val}.each do |tag|
      sort_tags_list[tag.first] = tag.second
    end

    return sort_tags_list
  end
end


