class ScreenshotsController < ApplicationController
  def save_screenshot
    user_id = params[:user_id]
    filename = params[:filename]

    if user_id.present? && filename.present?
      screenshot = Screenshot.new(user_id: user_id, image: filename)

      if screenshot.save
        render json: { message: "Screenshot saved successfully!", screenshot: screenshot }, status: :ok
      else
        render json: { errors: screenshot.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Missing user_id or filename" }, status: :bad_request
    end
  end
end
  