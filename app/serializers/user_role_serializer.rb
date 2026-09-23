class UserRoleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :label, :is_admin
  has_many :users
end
