class TaskCompletion < ApplicationRecord
  belongs_to :task

  validates :completed_at, presence: true

  scope :today, -> {
    today_start = Date.current.beginning_of_day
    today_end = Date.current.end_of_day
    where(completed_at: today_start..today_end)
  }
  scope :for_date, ->(date) {
    date_start = date.beginning_of_day
    date_end = date.end_of_day
    where(completed_at: date_start..date_end)
  }
  scope :between_dates, ->(start_date, end_date) {
    where(completed_at: start_date.beginning_of_day..end_date.end_of_day)
  }
end
