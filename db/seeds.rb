seed_users = [
  { full_name: "Ada Admin", email: "admin@example.com", role: :admin, password: "SecurePass123!" },
  { full_name: "Grace Member", email: "member@example.com", role: :user, password: "SecurePass123!" }
]

seed_users.each do |attributes|
  user = User.find_or_initialize_by(email: attributes[:email])
  user.assign_attributes(attributes)
  unless user.avatar_image.attached?
    user.avatar_image.attach(
      io: File.open(Rails.root.join("public/icon.png")),
      filename: "umanni-avatar.png",
      content_type: "image/png"
    )
  end
  user.save!
end
