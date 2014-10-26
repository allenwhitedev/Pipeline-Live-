class UserMailer < ActionMailer::Base
  default from: "from@Pipeline.com"

  def account_active

  end

  def reset_password(user)
  	@user = user


  	mail to: user.email, subject: "Password Reset"
  	flash.now[:success] = "An email with the password reset link was sent"
  	redirect_to @user #This redirect then send user to login page(untested)
  end



end