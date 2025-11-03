class ReportsController < ApplicationController
  def index
    @tasks = Task.all.order(:name)
    @days = params[:days]&.to_i || 30

    # Get date range
    @start_date = @days.days.ago.to_date
    @end_date = Date.current

    # Get completions for the date range
    completions = TaskCompletion.between_dates(@start_date, @end_date).includes(:task)

    # Group completions by date and task_id
    @completions_by_date = {}
    completions.each do |completion|
      date = completion.completed_at.to_date
      task_id = completion.task_id
      @completions_by_date[[date, task_id]] = true
    end

    # Build completion calendar for each task
    @task_completions = {}
    @tasks.each do |task|
      @task_completions[task.id] = (@start_date..@end_date).map do |date|
        completed = @completions_by_date[[date, task.id]] || false
        { date: date, completed: completed }
      end
    end
  end
end
