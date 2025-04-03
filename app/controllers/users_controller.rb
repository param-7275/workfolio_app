
class UsersController < ApplicationController
  before_action :current_user, only: [:new_owner]

  def index
  end

  def new_signup
    @user = User.new
  end

  def activity
  end
  def user_signup
    @user = User.create(user_params)
    if @user.password != @user.password_confirmation
      flash[:error] = "password should be match"
    end
      
		if @user.save
			flash[:success] = "Account Sucessfully Created"
      redirect_to login_path
		else
			flash[:error] = @user.errors.full_messages
			render :new_signup
		end
  end

  def new_owner
		render :new_owner
	end

	def create_user
		@owner = User.new(owner_params)
		if @owner.save
			flash[:success] = "Owner Sucessfully Created"
      # OwnerMailer.with(user: @user).welcome_email.deliver_now  
      redirect_to admin_index_path
		else
			flash[:error] = @owner.errors.full_messages
			render :new_owner
		end
	end
  

  def new_login
		@user = User.new
	end

  def user_login
    @user = User.find_by(email: params[:email])
    if @user.present?
      if @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id
        flash[:success] = "Login Sucessfully"
        redirect_to work_session_index_path
      else
        flash[:error] = "Invalid email or password"
        render :new_login
      end
    else
      flash[:error] = "No user found with this email"
      render :new_login
    end
  end

	def destroy
		if session[:user_id].present?
			session[:user_id] = nil
      stop_screenshot_capture(current_user.id)
			flash[:success] = 'User successfully logged out.'
		end
		redirect_to login_path
	end

  # def current_user
  #   if session[:user_id]
  #     @user = User.find_by(id: session[:user_id])
  #   else
  #     redirect_to login_path
  #     flash[:error] = "Must be login"
  #   end
  # end

  def current_user
    @user ||= User.find_by(id: session[:user_id])
    redirect_to login_path, flash: { error: "Must be logged in" } unless @user
  end

  private

  def stop_screenshot_capture(user_id)
    system("pkill -f 'python scripts/screenshot_uploader.py #{user_id}'")
  end

	def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :phone_number)
  end
end
