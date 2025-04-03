require 'sidekiq'
require 'sidekiq/cron/job'

Sidekiq::Cron::Job.create(
  name: 'Auto Clock Out Worker - every minute', 
  cron: '* * * * *', 
  class: 'AutoClockOutWorker'
)