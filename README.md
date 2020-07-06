# Fullstack Developer Test

- Check this readme.md
- Create a branch to develop your task
- Push to remote in 1 week (date will be checked from branch creation/assigned date)

# Requirements:
- Latest version of the stack
- Write unit and integration tests 
- Deliver with a working Dockerfile
- Use docker-compose.yml if needed
- Show your best practices ex: design patters, linters etc.

# The Test
Here we'll try to simulate a "real sprint" that you'll, probably, be assigned while working as Fullstack at Umanni.
# The Task
- Create a responsive application to manage users.
- A user must have:
1- full_name
2- email
3- avatar_image (upload from file or url)
4- role (admin/no-admin)
# The App
## Admin Use cases
- As an Admin, I must be able to access a User Admin Dashboard.
- As an Admin, I must be able to see on Dashboard:
  - Total number of Users
  - Total number of Users grouped by Role
- As an Admin, I must be redirected to User Admin Dashboard after login
- As an Admin, I must be able to list, create, edit and delete Users.
- As an Admin, I must be able to toggle the User Role.
- As an Admin, I must be able to import a Spreadsheet into the system, in order to create new Users
- As an Admin, I must be able to see the progress of Users imports.
## User Use Cases
- As an User, I must be redirected to my Profile after login
- As an User, I must be able only to see my info, edit and delete my profile.
## Visitor Use Cases
- As a Visitor, I can register myself as a normal User.

# The Start.
- Your deadline is 1 week after accepting this test. 
# The Rules
These one are required. Not doing one of them will invalidate your submission.
- You must write down a README in English explaining how to build and run your app.
- The Frontend must  have a framework Bootstrap, Foundation, MDL or any other frameworks, remember you are here as a Fullstack not a backend developer.
- You must use realtime related stuff (counters on Admin Dashboard, import progress, etc)
- You must treat errors accordingly.
- You must use a open source lib to authenticate Users.
- And, of course, if you're doing this test, we assume that you have knowledge of git (clone, commit, push, pull, fetch, rebase, merge, stash), and be acquainted with github niceties such as Pull Request based on workflows.
# What we're expecting to see:
- Use SCSS to your CSS;
- .gitignore, .dockerignore
- A proper way to manage app configuration 
- Consider multiple Browser support ex: Edge, Chrome, Firefox and Safari.
- Organize & optimize your code and images
- Form validation (frontend validation included)
- Tests with at least 90% coverage
- Be able to use, pjax, turbolinks, intercooler, unpoly (yes, we believe in good old server side rendering)
# Extra points
- Use a Dockerfile
- docker-compose.yml
- React in some ui components when it makes sense
- Stress tests
# What will be assessed
- Code's Semantic, Cleanness and Maintainability;
- Understanding of REST and proper use of HTTP Methods (POST, GET, PUT, PATCH, DELETE, OPTIONS);
- Basic Security tests against Injections, XSS/XSRF, ...
