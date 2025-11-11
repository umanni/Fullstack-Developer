class UserSearchService < ApplicationService
  def initialize(search_params, current_user)
    @search_params = search_params
    @current_user = current_user
  end

  def call
    return failure("Unauthorized access") unless can_search?

    users = build_search_query
    success({
      users: users,
      total_count: users.count,
      filters_applied: filters_applied?
    })
  end

  private

  attr_reader :search_params, :current_user

  def can_search?
    current_user&.admin?
  end

  def build_search_query
    query = User.all
    query = apply_search_filter(query)
    query = apply_role_filter(query)
    query = apply_date_filter(query)
    query = apply_sorting(query)
    query
  end

  def apply_search_filter(query)
    return query if search_params[:search].blank?

    search_term = "%#{search_params[:search].strip}%"
    query.where(
      "full_name ILIKE ? OR email ILIKE ?",
      search_term, search_term
    )
  end

  def apply_role_filter(query)
    return query if search_params[:role].blank?

    query.where(role: search_params[:role])
  end

  def apply_date_filter(query)
    return query unless search_params[:date_from].present? || search_params[:date_to].present?

    if search_params[:date_from].present?
      query = query.where("created_at >= ?", Date.parse(search_params[:date_from]))
    end

    if search_params[:date_to].present?
      query = query.where("created_at <= ?", Date.parse(search_params[:date_to]).end_of_day)
    end

    query
  rescue Date::Error
    query
  end

  def apply_sorting(query)
    sort_by = search_params[:sort_by]&.to_s
    sort_direction = search_params[:sort_direction]&.to_s

    case sort_by
    when "name"
      query.order("full_name #{sort_direction == 'desc' ? 'DESC' : 'ASC'}")
    when "email"
      query.order("email #{sort_direction == 'desc' ? 'DESC' : 'ASC'}")
    when "role"
      query.order("role #{sort_direction == 'desc' ? 'DESC' : 'ASC'}")
    when "created_at"
      query.order("created_at #{sort_direction == 'desc' ? 'DESC' : 'ASC'}")
    else
      query.order(created_at: :desc)
    end
  end

  def filters_applied?
    search_params[:search].present? ||
      search_params[:role].present? ||
      search_params[:date_from].present? ||
      search_params[:date_to].present?
  end
end
