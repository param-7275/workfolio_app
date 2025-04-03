ActiveAdmin.register Screenshot do
  permit_params :user_id, :image

  index do
    selectable_column
    column :id
    column :user
    column :created_at
    column "Screenshot" do |screenshot|
      if screenshot.image.attached?
        image_tag url_for(screenshot.image), size: "100x100"
      end
    end
    actions
  end
end
  