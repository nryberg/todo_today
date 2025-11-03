namespace :tasks do
  desc "Clean up old task completions (older than specified days, default 365)"
  task :cleanup_old_completions, [:days] => :environment do |t, args|
    days = (args[:days] || 365).to_i
    cutoff_date = days.days.ago

    count = TaskCompletion.where("completed_at < ?", cutoff_date).count
    TaskCompletion.where("completed_at < ?", cutoff_date).delete_all

    puts "Deleted #{count} task completions older than #{days} days"
  end

  desc "Show daily completion statistics"
  task daily_stats: :environment do
    today = Date.current
    tasks = Task.all
    completions_today = TaskCompletion.today.distinct.pluck(:task_id)

    puts "="*50
    puts "Daily Task Statistics for #{today.strftime('%B %d, %Y')}"
    puts "="*50
    puts "Total tasks: #{tasks.count}"
    puts "Completed today: #{completions_today.count}"
    puts "Remaining: #{tasks.count - completions_today.count}"
    puts "Completion rate: #{tasks.count > 0 ? (completions_today.count.to_f / tasks.count * 100).round(1) : 0}%"
    puts "="*50
  end
end
