
###### THESE WORK BELOW ######

# Delayed::Job.all.each(&:invoke_job)

# Delayed::Job.where("last_error is not null").each do |dj|
#   dj.run_at = Time.now.advance(seconds: 10)
#   dj.locked_at = nil
#   dj.locked_by = nil
#   dj.attempts = 0
#   dj.last_error = nil
#   dj.failed_at = nil
#   dj.save
# end

# Delayed::Job.all.each do |dj|
#   dj.run_at = Time.now.advance(seconds: 5)
#   dj.locked_at = nil
#   dj.locked_by = nil
#   dj.attempts = 0
#   dj.last_error = nil
#   dj.failed_at = nil
#   dj.save
# end


Delayed::Job.all.each do |d|
  d.last_error = nil
  d.run_at = Time.now
  d.failed_at = nil
  d.locked_at = nil
  d.locked_by = nil
  d.attempts = 0
  d.failed_at = nil # needed in Rails 5 / delayed_job (4.1.2)
  d.save!
end

###### Not TRIED YET BELOW ######

# Delayed::Worker.new.run(Delayed::Job.last)
# Delayed::Job.find(10).invoke_job
# Delayed::Job.find(10).destroy

# Delayed::Worker.new.run(Delayed::Job.find(id))

# Delayed::Job.first.update_attributes(:attempts=>0, :run_at=>Time.now, :failed_at => nil, :locked_by=>nil, :locked_at=>nil)

# dj = Delayed::Job.first; dj.run_at = Time.now; dj.attempts = 0; dj.save!;

# Delayed::Job.where.all.each {|dj| dj.run_at = Time.now; dj.attempts = 0; dj.save!}

# Delayed::Worker.new.run(Delayed::Job.last)

# Delayed::Job.find_each(batch_size: 100) { |d| Delayed::Worker.new.run(d) }

# Delayed::Job.all.each{|d| d.run_at = Time.now; d.save!}

# Delayed::Job.where("failed_at is not null").each do |dj| dj.run_at = Time.now; dj.last_error = nil; dj.failed_at = nil; dj.save! end

# d.last_error = nil
# d.run_at = Time.now
# d.failed_at = nil
# d.locked_at = nil
# d.locked_by = nil
# d.attempts = 0
# d.failed_at = nil # needed in Rails 5 / delayed_job (4.1.2)
# d.save!

# !YourClass.delay(run_at: Time.now).method

####### ORIGINAL SETTINGS BELOW: #######
# ORIG BELOW UNCOMMENTED
Delayed::Worker.destroy_failed_jobs = true
# Delayed::Worker.sleep_delay = 15
Delayed::Worker.max_attempts = 1
# Delayed::Worker.priority = 5
Delayed::Worker.max_run_time = 30.minutes
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))

# ORIG BELOW COMMENTED OUT
# Delayed::Worker.exit_on_complete = false
# Delayed::Worker.read_ahead = 1
# Delayed::Worker.default_queue_name = 'default'
# Delayed::Worker.delay_jobs = !Rails.env.test?
# Delayed::Worker.raise_signal_exceptions = :term
####### ORIGINAL SETTINGS ABOVE: #######

# Delayed::Worker.logger = Logger.new(STDOUT)



## SETTINGS BELOW FROM BLOG. - TRIAL

# Delayed::Worker.destroy_failed_jobs = false
# Delayed::Worker.sleep_delay = 60
# Delayed::Worker.max_attempts = 3
# Delayed::Worker.max_run_time = 5.minutes
# Delayed::Worker.read_ahead = 10
# # Delayed::Worker.default_queue_name = ‘default’
# Delayed::Worker.delay_jobs = !Rails.env.test?
# Delayed::Worker.raise_signal_exceptions = :term
# Delayed::Worker.logger = Logger.new(File.join(Rails.root, ‘log’, ‘delayed_job.log’))
