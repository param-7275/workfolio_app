ActiveAdmin.register User do
  actions :all, except: [:new, :destroy, :edit]
  index do
    selectable_column
    div do 
      "Total Users: #{User.count}"
    end
    id_column
    column :username
    column :email
    actions
  end

  show do
    attributes_table do
      row :username
      row :email
    end
    panel "Work Sessions (Daily Records)" do
      user.work_sessions.group_by { |ws| ws.clock_in.to_date }.each do |date, sessions|
        h3 date.strftime("%d %B %Y") 
        
        table_for sessions do
          column "Clock In" do |session|
            session.clock_in.strftime("%I:%M:%S %p") 
          end
          
          column "Clock Out" do |session|
            username = user.username.capitalize
            session.clock_out.present? ? session.clock_out.strftime("%I:%M:%S %p") : "#{username} Currently working"
          end
          
          column "Total Working Hours" do |session|
            if session.clock_out.present?
              total_seconds = (session.clock_out - session.clock_in).to_i
              hours = total_seconds / 3600
              minutes = (total_seconds % 3600) / 60
              seconds = total_seconds % 60
              "#{hours}h #{minutes}m #{seconds}s"
            else
              "-"
            end
          end
        end
      end
    end
  end
end