json.users do
  json.array! @users, :id, :first_name, :last_name, :image, :email, :profile
end 