# How to run the code properly

- Install docker (https://forums.linuxmint.com/viewtopic.php?t=414617)
- Clone the repository
- Run the following commands in the terminal:
- sudo docker compose build
- sudo docker compose up 
- docker compose exec web rails db:create db:migrate db:seed (in another terminal)
- docker compose exec web bundle exec rspec (if you want to run tests)

- quick alert: maybe docker conflicts with postgresql, if so, temporarily turn off postgresql (systemctl stop postgresql)
- if you dont want to use sudo, you can give permission with sudo usermod -aG docker $USER

# About the system:
- One Admin account will be created at the start of the server with the following credentials:
  Username: Admin User 
  Password: 123456
- The Spreadsheet must be created with the following format:
  At the first line: username, password, email
  And the lines below must be the users data (users imports are always created with role = 0 = user)
 