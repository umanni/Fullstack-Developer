class DashboardStatsService < ApplicationService
  def initialize(current_user)
    @current_user = current_user
  end

  def call
    return failure("Unauthorized access") unless can_access_dashboard?

    stats = calculate_dashboard_stats
    success(stats)
  end

  private

  attr_reader :current_user

  def can_access_dashboard?
    current_user&.admin?
  end

  def calculate_dashboard_stats
    {
      users: user_statistics,
      imports: import_statistics,
      activity: activity_statistics,
      growth: growth_statistics
    }
  end

  def user_statistics
    {
      total: User.count,
      admins: User.where(role: "admin").count,
      users: User.where(role: "user").count,
      recent: User.with_attached_avatar_image.order(created_at: :desc).limit(4),
      created_today: User.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count,
      created_this_week: User.where(created_at: 1.week.ago..Time.current).count,
      created_this_month: User.where(created_at: 1.month.ago..Time.current).count
    }
  end

  def import_statistics
    {
      total: Import.count,
      pending: Import.where(status: "pending").count,
      processing: Import.where(status: "processing").count,
      completed: Import.where(status: "completed").count,
      failed: Import.where(status: "failed").count,
      recent: Import.order(created_at: :desc).limit(5)
    }
  end

  def activity_statistics
    {
      users_created_today: User.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count,
      imports_started_today: Import.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count,
      last_activity: [
        User.maximum(:updated_at),
        Import.maximum(:updated_at)
      ].compact.max
    }
  end

  def growth_statistics
    growth_data = (0..29).map do |days_ago|
      date = days_ago.days.ago.to_date
      {
        date: date,
        users_created: User.where(created_at: date.beginning_of_day..date.end_of_day).count
      }
    end.reverse

    {
      daily_growth: growth_data,
      total_growth_30_days: User.where(created_at: 30.days.ago..Time.current).count,
      average_daily_growth: growth_data.sum { |d| d[:users_created] } / 30.0
    }
  end
end
