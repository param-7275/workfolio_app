class WorkSessionsController < ApplicationController
  before_action :authenticate_user!
 
  def clock_in
    @work_session = current_user.work_sessions.create(clock_in: Time.current.in_time_zone("Asia/Kolkata"))
    flash[:notice] = "Clocked in successfully!"
    start_screenshot_capture(current_user.id)
    redirect_to work_session_index_path
  end
 
  def start_break
    @work_session = current_user.work_sessions.last
    if @work_session && @work_session.clock_in
      # Reset break_end to allow for multiple breaks
      @work_session.update(break_start: Time.current, break_end: nil)
      flash[:notice] = "Break started!"
      pause_screenshot_capture(current_user.id)
    else
      flash[:alert] = "You need to clock in first."
    end
    redirect_to work_session_index_path
  end
 
  def end_break
    @work_session = current_user.work_sessions.last
    if @work_session && @work_session.break_start && @work_session.break_end.nil?
      @work_session.update(break_end: Time.current)
      flash[:notice] = "Break ended!"
      resume_screenshot_capture(current_user.id)
    else
      flash[:alert] = "You need to start a break first."
    end
    redirect_to work_session_index_path
  end
#  paramjeet singh
  def clock_out
    @work_session = current_user.work_sessions.last
    if @work_session && @work_session.clock_in && @work_session.clock_out.nil?
      @work_session.update(clock_out: Time.current, total_hours: @work_session.calculate_total_hours)
      flash[:notice] = "Clocked out successfully!"
      stop_screenshot_capture(current_user.id)
    else
      flash[:alert] = "You need to clock in first."
    end
    redirect_to work_session_index_path
  end
 
  def index
    @work_sessions = current_user.work_sessions.order(created_at: :desc)
  end
 
  def user_work_session_report
    @user = User.find(params[:id])
    @work_sessions = @user.work_sessions.group_by { |ws| ws.clock_in.to_date }
  end
 
  private
 
  def start_screenshot_capture(user_id)
    # Kill any existing process first to avoid duplicates
    stop_screenshot_capture(user_id)
    
    # Start a new process
   script_path = "C:/Users/Dell/OneDrive/Desktop/workfolio_app/workfolio_copy/scripts/screenshot_uploader.py"
    pid = spawn("python3 #{script_path} #{user_id}")
    Process.detach(pid)
    
    # Create status file indicating active status
    status_file = ensure_status_file(user_id)
    
    # Wait briefly for the Python script to create its own status file
    sleep(1)
    
    # If the script hasn't created the file yet, create it ourselves
    unless File.exist?(status_file)
      File.write(status_file, JSON.generate({ active: true, pid: pid }))
    end
  end
  
  def pause_screenshot_capture(user_id)
    status_file = ensure_status_file(user_id)
    if File.exist?(status_file)
      # Read current status to preserve PID
      current_status = JSON.parse(File.read(status_file)) rescue {}
      # Update to inactive
      current_status["active"] = false
      current_status["last_update"] = Time.current.iso8601
      File.write(status_file, JSON.generate(current_status))
    end
  end
  
  def resume_screenshot_capture(user_id)
    status_file = ensure_status_file(user_id)
    if File.exist?(status_file)
      # Read current status to preserve PID
      current_status = JSON.parse(File.read(status_file)) rescue {}
      # Update to active
      current_status["active"] = true
      current_status["last_update"] = Time.current.iso8601
      File.write(status_file, JSON.generate(current_status))
    else
      # If no status file exists, restart the process
      start_screenshot_capture(user_id)
    end
  end
  
  def stop_screenshot_capture(user_id)
    status_file = ensure_status_file(user_id)
    
    if File.exist?(status_file)
      begin
        # Try to get PID from status file
        status = JSON.parse(File.read(status_file))
        pid = status["pid"]
        
        # Terminate process if PID exists
        if pid
          # Send SIGTERM signal
          Process.kill("TERM", pid.to_i) rescue nil
        end
      rescue
        # Fallback: try to find process by pattern matching
        system("pkill -f 'python3.*screenshot_uploader\.py.*#{user_id}'")
      end
      
      # Remove status file
      File.delete(status_file) rescue nil
    else
      # Fallback: try to find process by pattern matching
      system("pkill -f 'python3.*screenshot_uploader\.py.*#{user_id}'")
    end
  end
end
 