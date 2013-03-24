class UsersController < ApplicationController
  load_and_authorize_resource
  
  # GET /users
  # GET /users.json
  def index
    @users = User.all
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.blogs.destroy_all
    @user.destroy
    
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end
  
  def current_ability
    if current_user
      if @user == current_user
        def current_user.admin?
          true
        end
      end
    end
    
    @current_ability ||= Ability.new(current_user)
  end
end
