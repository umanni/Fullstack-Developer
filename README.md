# Fullstack-Developer TEST UMANNI 

This is a developper test by umanni. A responsive user management system.
Main features:

- Admin dashboard: a stats from all users grouped by role
- User management (CRUD): admins can create, read, update and delete any user
- Profile management: Regular users can CRUD their own profile
- CSV import: Admins can bulk import new users via CSV files.

### Versions used in this project
<div align="center">

|System|  Version Command  | Version |
|:------|:-------------------:|:---------:|
|[ruby](https://www.ruby-lang.org/en/documentation/installation/)| `ruby -v`|`3.4.5`  |
|[rails](https://guides.rubyonrails.org/)|`rails -v`|`8.0.4`|
|[redis](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/)/valkey|`redis-cli -v`| `valkey-cli 8.1.4` |
|[postgreSQL](https://www.postgresql.org/download/)| `psql -V`| `18` |
|[tailwind](https://tailwindcss.com/blog/tailwindcss-v4)| `npm view tailwindcss version`| `4.1.16` |
|[node](https://nodejs.org/en) | `node -v`| `v25.1.0` |

</div>

## Clone or download this repo

```
git clone git@github.com:vitaoTM/Fullstack-Developer.git
cd Fullstack-Developer
```

## Get Started with Docker

1. Build and Run the app

```
docker-compose build 
docker-compose up -d 
```

2. Set up database

```
docker-compose exec web bin/rails db:setup
```

3. Create admin User
   
You'll need to create the first user via rails console


```
# Start the console:

docker-compose exec web bin/rails console

# inside the console, run:

u = User.create(full_name: "Adim User", email: "admin@admim.com", password: "password123", password_confirmation: "password123")
u.admin!
u.save

# To exit rails console type:

exit
```

4. Access the app

The application should be runnig:
- Check: `http://localhost:3000`
- Log in with the credentials you just created.

5. Stopping the application

To stop all running Docker containers:
```
docker-compose down
```

## Get Started Locally

To run locally please check:
- Ruby version file: `.ruby-version`
- Rails: see `Gemfile`
- PostgreSQL: Must be installed and runnig.
- Node & Yarn: Make sure its all installed.


1. Setup Database and install gems and JS packages

```
bundle install 
yarn install
bin/rails db:create db:migrate

```

2. Create Admin User

- Create admin user, must be done through rails console:

- Do not forget to change your credentials:

```
rails console

# You will enter rails console:
# run:

# This will create a admin user if you do not read this and only copy and paste to your terminal (you can delete this line)

adm = User.create(full_name: "Admin", email: "admin@admin.com", password: "123456", password_confirmation: "123456")
adm.admin!

u = User.create(full_name: "ADD YOU NAME HERE", email: "ADD YOUR EMAIL HERE", password: "SET A PASSWORD", password_confirmation: "CONFIRM YOUR PASSWORD")

u.admin!

exit

```

3. Run The App

```
bin/dev
```
- Access the app at `http://localhost:3000`

- To exit server just press Ctrl-C

4. Run Tests (Local):

```
rspec spec/
```


<!---->
<!-- # Fullstack Developer Test -->
<!---->
<!-- - Check this readme.md -->
<!-- - Create a branch to develop your task -->
<!-- - Push to remote in 1 week (date will be checked from branch creation/assigned date) -->
<!---->
<!-- # Requirements: -->
<!-- - Latest version of the stack -->
<!-- - Write unit and integration tests  -->
<!-- - Deliver with a working Dockerfile -->
<!-- - Use docker-compose.yml if needed -->
<!-- - Show your best practices ex: design patters, linters etc. -->
<!---->
<!-- # The Test -->
<!-- Here we'll try to simulate a "real sprint" that you'll, probably, be assigned while working as Fullstack at Umanni. -->
<!-- # The Task -->
<!-- - Create a responsive application to manage users. -->
<!-- - A user must have: -->
<!-- 1- full_name -->
<!-- 2- email -->
<!-- 3- avatar_image (upload from file or url) -->
<!-- 4- role (admin/no-admin) -->
<!-- # The App -->
<!-- ## Admin Use cases -->
<!-- - As an Admin, I must be able to access a User Admin Dashboard. -->
<!-- - As an Admin, I must be able to see on Dashboard: -->
<!--   - Total number of Users -->
<!--   - Total number of Users grouped by Role -->
<!-- - As an Admin, I must be redirected to User Admin Dashboard after login -->
<!-- - As an Admin, I must be able to list, create, edit and delete Users. -->
<!-- - As an Admin, I must be able to toggle the User Role. -->
<!-- - As an Admin, I must be able to import a Spreadsheet into the system, in order to create new Users -->
<!-- - As an Admin, I must be able to see the progress of Users imports. -->
<!-- ## User Use Cases -->
<!-- - As an User, I must be redirected to my Profile after login -->
<!-- - As an User, I must be able only to see my info, edit and delete my profile. -->
<!-- ## Visitor Use Cases -->
<!-- - As a Visitor, I can register myself as a normal User. -->
<!---->
<!-- # The Start. -->
<!-- - Your deadline is 1 week after accepting this test.  -->
<!-- # The Rules -->
<!-- These one are required. Not doing one of them will invalidate your submission. -->
<!-- - You must write down a README in English explaining how to build and run your app. -->
<!-- - The Frontend must  have a framework Bootstrap, Foundation, MDL or any other frameworks, remember you are here as a Fullstack not a backend developer. -->
<!-- - You must use realtime related stuff (counters on Admin Dashboard, import progress, etc) -->
<!-- - You must treat errors accordingly. -->
<!-- - You must use a open source lib to authenticate Users. -->
<!-- - And, of course, if you're doing this test, we assume that you have knowledge of git (clone, commit, push, pull, fetch, rebase, merge, stash), and be acquainted with github niceties such as Pull Request based on workflows. -->
<!-- # What we're expecting to see: -->
<!-- - Use SCSS to your CSS; -->
<!-- - .gitignore, .dockerignore -->
<!-- - A proper way to manage app configuration  -->
<!-- - Consider multiple Browser support ex: Edge, Chrome, Firefox and Safari. -->
<!-- - Organize & optimize your code and images -->
<!-- - Form validation (frontend validation included) -->
<!-- - Tests with at least 90% coverage -->
<!-- - Be able to use, pjax, turbolinks, intercooler, unpoly (yes, we believe in good old server side rendering) -->
<!-- # Extra points -->
<!-- - Use a Dockerfile -->
<!-- - docker-compose.yml -->
<!-- - React in some ui components when it makes sense -->
<!-- - Stress tests -->
<!-- # What will be assessed -->
<!-- - Code's Semantic, Cleanness and Maintainability; -->
<!-- - Understanding of REST and proper use of HTTP Methods (POST, GET, PUT, PATCH, DELETE, OPTIONS); -->
<!-- - Basic Security tests against Injections, XSS/XSRF, ... -->
