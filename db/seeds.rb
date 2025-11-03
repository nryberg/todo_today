# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
Task.destroy_all

puts "Creating sample tasks..."

# Create sample tasks
tasks = [
  "Drink 8 glasses of water",
  "Exercise for 30 minutes",
  "Read for 20 minutes",
  "Meditate for 10 minutes",
  "Practice gratitude journaling",
  "Take vitamins",
  "Walk 10,000 steps",
  "Eat 5 servings of fruits/vegetables",
  "Get 8 hours of sleep",
  "Learn something new",
  "Call a friend or family member",
  "Clean one area of the house",
  "Plan tomorrow's priorities",
  "Practice deep breathing",
  "Stretch for 10 minutes"
]

created_tasks = []
tasks.each do |task_name|
  task = Task.create!(name: task_name)
  created_tasks << task
  puts "✓ Created task: #{task_name}"
end

puts "\nCreating sample completion history..."

# Create some historical completion data for demonstration
# This will create completions for the past 30 days with varying completion rates
created_tasks.each do |task|
  # Each task gets a different completion rate to show variety in reports
  completion_probability = rand(0.3..0.9) # 30% to 90% completion rate

  (30.days.ago.to_date..Date.current).each do |date|
    # Skip today - let user complete today's tasks themselves
    next if date == Date.current

    if rand < completion_probability
      # Random time during the day
      random_time = date.beginning_of_day + rand(16.hours)
      TaskCompletion.create!(
        task: task,
        completed_at: random_time
      )
    end
  end

  completion_count = task.task_completions.count
  puts "  → Added #{completion_count} completions for '#{task.name}'"
end

puts "\n🎉 Seed data created successfully!"
puts "#{Task.count} tasks created with completion history"
puts "Run 'rails server' to start the application"
