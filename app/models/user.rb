class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :tasks, dependent: :destroy
  has_many :task_completions, through: :tasks

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  # For social login - find or create user from OAuth data
  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0, 20]
      user.avatar_url = auth.info.image
    end
  end

  # Display name for UI
  def display_name
    name.present? ? name : email.split('@').first
  end

  # Check if user signed up via social login
  def social_login?
    provider.present? && uid.present?
  end

  # User's completion rate across all tasks
  def overall_completion_rate(days = 30)
    return 0 if tasks.empty?

    total_possible = tasks.count * days
    total_completed = task_completions
      .where(completed_at: days.days.ago.beginning_of_day..Date.current.end_of_day)
      .group_by { |tc| [tc.task_id, tc.completed_at.to_date] }
      .keys
      .count

    return 0 if total_possible.zero?
    (total_completed.to_f / total_possible * 100).round(1)
  end

  # Get user's tasks sorted by completion status
  def sorted_tasks
    user_tasks = tasks.includes(:task_completions)

    incomplete_tasks = []
    completed_tasks = []

    user_tasks.each do |task|
      if task.completed_today?
        completed_tasks << task
      else
        incomplete_tasks << task
      end
    end

    incomplete_tasks.sort_by(&:name) + completed_tasks.sort_by(&:name)
  end
end
