class ApplicationController < ActionController::Base
  require 'fileutils'
  helper_method :current_user
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authenticate_user!
    redirect_to login_path, alert: "Please login first" unless current_user
  end


  def ensure_status_file(user_id)
    status_file = "/tmp/screenshot_status_#{user_id}.json"
    dir = File.dirname(status_file)

    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.write(status_file, "{}") unless File.exist?(status_file)

    status_file
  end
end
  