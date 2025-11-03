class Task < ApplicationRecord
  belongs_to :user
  has_many :task_completions, dependent: :destroy

  validates :name, presence: true
  validates :user, presence: true

  def completed_today?
    today_start = Date.current.beginning_of_day
    today_end = Date.current.end_of_day
    task_completions.where(completed_at: today_start..today_end).exists?
  end

  def completion_rate(days = 30)
    start_date = days.days.ago.to_date
    end_date = Date.current
    total_days = (start_date..end_date).count

    # Get distinct dates when task was completed
    completed_dates = task_completions
      .where(completed_at: start_date.beginning_of_day..end_date.end_of_day)
      .group_by { |tc| tc.completed_at.to_date }
      .keys
      .count

    return 0 if total_days.zero?
    (completed_dates.to_f / total_days * 100).round(1)
  end
end
