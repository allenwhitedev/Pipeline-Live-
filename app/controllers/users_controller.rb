class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :index, :destroy, :attending]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  before_action :get_user, only: [:reset_password, :reset_password_submit]

	def create
		@user = User.new(user_params)
		if @user.save
			sign_in @user
      current_user.join!(Organization.find(1)) #temp for demo, users should auto join their organization through separate 
      # organization login/signup pages
			flash[:success] = "Welcome to the Pipeline, you can now check in to events and join other organizations"
			redirect_to events_url
		else
			render 'new'
		end
	end

	def destroy
		User.find(params[:id]).destroy
		flash[:success] = "User deleted"
		redirect_to users_url
	end
  
	def edit
	end

	def update
		@user = User.find(params[:id])
		if @user.update_attributes(user_params)
			flash[:success] = "Profile Updated"
			redirect_to @user
		else
			render 'edit'
		end
	end

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
  	@events = @user.events.paginate(page: params[:page])
  end

  def index
  	@users = User.paginate(page: params[:page])
  end

   def attending
    @title = "Attending" # get rid of this and go through show_attend view for users
    @user = User.find(params[:id])
    @events = @user.attended_events.paginate(page: params[:page])
    render 'show_attend'
  end

  def password_reset_request
  	@user = User.find_by(email: params[:password_reset_request][:email].downcase)
  	if @user
  		@user.create_reset_digest
  		UserMailer.reset_password(@user).deliver
  		flash.now[:info] = "Password reset sent. Check your email now."
  		render 'forgot_password'
  	else
  		flash.now[:danger] = "Email address not found"
      render 'forgot_password'
  	end
  end

  def reset_password
  end

  def reset_password_submit
  		if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to root_url 
    elsif @user.update_attributes(pr_params)
      if (params[:user][:password].blank? &&
          params[:user][:password_confirmation].blank?)
        flash.now[:danger] = "Password/confirmation can't be blank" #don't think this ever gets executed
        render 'reset_password'
      else
        flash[:success] = "Password has been reset."
        sign_in @user
        redirect_to @user
      end
    else
      render 'reset_password'
    end
  end


private

def admin_user
	redirect_to(root_url) unless current_user.admin?
end

	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end

	def pr_params
		params.require(:user).permit(:password, :password_confirmation)
	end

	def correct_user
		@user = User.find(params[:id])
		redirect_to root_url unless current_user?(@user)
	end

		def get_user
    @user = User.find_by(email: params[:email])
    unless !@user.email.nil? 
    	flash[:danger] = @user.name
      redirect_to root_url
    end
  end

end
