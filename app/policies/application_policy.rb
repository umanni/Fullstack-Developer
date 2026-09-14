class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = false
  def show? = false
  def create? = false
  def update? = false
  def destroy? = false

  # `authorize!` derives the predicate from `action_name`, so the two actions
  # that only render a form need predicates of their own. They mirror the write
  # they lead to: seeing the form is exactly as privileged as submitting it.
  def new? = create?
  def edit? = update?

  def permitted_attributes = []

  private

  def owner? = record.is_a?(User) && user == record
end
