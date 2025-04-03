class AutoClockOutWorker
  include Sidekiq::Worker
  def perform
    WorkSession.where(clock_out: nil).each do |session|
      if session.clock_in && session.clock_in <= 15.hours.ago
        session.update(clock_out: Time.current, total_hours: session.calculate_total_hours)
      end
    end
  end
end