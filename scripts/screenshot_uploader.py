import os
import datetime
import time
import sys
import json
import signal
import atexit
 
# Get user_id from command line arguments
user_id = sys.argv[1] if len(sys.argv) > 1 else "unknown"
 
# Configure screenshot directory
SCREENSHOT_DIR = "screenshots"
os.makedirs(SCREENSHOT_DIR, exist_ok=True)
 
# Status file path
STATUS_FILE = f"/tmp/screenshot_status_{user_id}.json"
 
# Save PID to status file on startup
def save_status(active=True):
    status = {
        "pid": os.getpid(),
        "active": active,
        "last_update": datetime.datetime.now().isoformat()
    }
    with open(STATUS_FILE, 'w') as f:
        json.dump(status, f)
 
# Check if we should be active
def should_be_active():
    try:
        if os.path.exists(STATUS_FILE):
            with open(STATUS_FILE, 'r') as f:
                status = json.load(f)
                return status.get("active", False)
        return False
    except Exception as e:
        print(f"Error reading status file: {e}")
        return False
 
# Take a screenshot
def take_screenshot():
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    filename = os.path.join(SCREENSHOT_DIR, f"screenshot_{user_id}_{timestamp}.png")
    
    # Use ImageMagick's import command
    result = os.system(f"import -window root {filename}")
    
    if result == 0:
        print(f"Screenshot saved: {filename}")
    else:
        print(f"Failed to take screenshot")
    
    return filename
 
# Clean up function
def cleanup():
    print(f"Screenshot capture for user {user_id} stopped")
    if os.path.exists(STATUS_FILE):
        try:
            os.remove(STATUS_FILE)
        except:
            pass
 
# Register cleanup function
atexit.register(cleanup)
 
# Handle termination signals
def handle_signal(sig, frame):
    print(f"Received signal {sig}, exiting...")
    sys.exit(0)
 
signal.signal(signal.SIGTERM, handle_signal)
signal.signal(signal.SIGINT, handle_signal)
 
# Initial status
save_status(True)
print(f"Screenshot capture started for user {user_id}")
 
# Main loop
while True:
    if should_be_active():
        take_screenshot()
    else:
        print("Screenshot capture paused")
    
    # Update status periodically
    save_status(should_be_active())
    
    # Sleep for 30 seconds
    time.sleep(30)
 

# import os
# import datetime
# import time
# import sys
 
# try:
#     import pyautogui
# except ImportError:
#     print("Installing pyautogui...")
#     os.system("pip install pyautogui")
#     import pyautogui
# print('--------------------------------------------------------------------------------')
# print(f"Received arguments: {sys.argv}")
# user_id = sys.argv[1] if len(sys.argv) > 1 else "unknown"
# print(f"Extracted user_id: {user_id}")
# SCREENSHOT_DIR = "screenshots"
# os.makedirs(SCREENSHOT_DIR, exist_ok=True)
 
# def take_screenshot():
#     timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
#     filename = os.path.join(SCREENSHOT_DIR, f"screenshot_{timestamp}.png")
#     print(user_id)
#     try:
#         screenshot = pyautogui.screenshot()
#         screenshot.save(filename)
        
#         print(f"Screenshot saved: {filename}")
#         return filename
#     except Exception as e:
#         print(f"Error taking screenshot: {e}")
#         return None
 
# while True:
#     take_screenshot()
#     time.sleep(20)