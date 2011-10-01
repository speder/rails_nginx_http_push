namespace :jobs do
  desc 'Display failed delayed_jobs'
  task :failed => :environment do
    Delayed::Job.where('failed_at is not null').each do |job|
      puts
      puts job.handler
      puts
      puts job.last_error.gsub('\\n', "\n")
      puts
    end
  end
end
