namespace :jobs do
  desc 'Display delayed_job environment (options: key=HOME refresh=true)'
  task :env => :environment do
    job_env_path = File.join(Rails.root, 'log/delayed_job_env.yml')

    if ENV['refresh']
      puts "Deleting #{job_env_path}"
      File.unlink(job_env_path)
    end

    job_env = if File.exists?(job_env_path)
      YAML.load_file(job_env_path)
    else
      Delayed::Job.enqueue(JobEnv.new(job_env_path))
      puts "Submitting Job to write environment to #{job_env_path}\nPlease repeat this command"
      nil
    end

    puts(job_env.respond_to?(:map) ? job_env.map{ |k, v| "#{k}=#{v}" }.join("\n") : job_env)
  end
  
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
