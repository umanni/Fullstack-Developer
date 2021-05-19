# Users Managing Rails App (Solution submitted by Krista Calleja)

This is an attempt to a solution for the challenge posed by Umanni for the position of Full-Stack Developer within the Tech team. 

## Table of contents

- [Overview](#overview)
  - [The challenge](#the-challenge)
  - [Run the app](#run-the-app)
- [My process](#my-process)
  - [Built with](#built-with)
  - [What I learned](#what-i-learned)
  - [Continued development](#continued-development)
  - [Useful resources](#useful-resources)
- [Author](#author)
- [Acknowledgments](#acknowledgments)

## Overview

### The challenge

Create a responsive application to manage users.

### Run the app

Setting up the app requires the pre-installation of github and Ruby version 2.6.6, at least. To double check the version of your current system run, 
```bash
ruby -v
```
You should see something starting with, ruby 2.6.6p.

Once you have cloned the repo to your system, you need to create and setup the database, therefore you should run, 
```bash
bundle && yarn
rails db:drop db:create db:migrate db:seed
```

Once your database is created and seeded, you may start the Rails server using the following command, 
```
rails s
```

Now open your browser and navigate to URL http://localhost:3000

You will be greated with the Users Managing Rails App Homepage, where, as a visitor you may Sign Up, or Login, if you're Admin or User.

If you'd like to sign in as an Admin use the following login credentials:
Email: jessica@chan.com
Password: 1234567890

## My process

### Built with

This project was initiated using a minimal Rails app template, with the Devise gem already installed. I used Bootstrap for some basic styling, with SCSS, as well as Simple Form. (See more info at: [Rails Templates](https://github.com/lewagon/rails-templates/tree/master#minimal))

The Gemfile also indicates the installation of the CanCan gem, which I intended to use for the purpose of differentiating between the Admin and User use cases. See section below [Continued development](#continued-development). 

### What I learned

This project presented a breakthrough in my learning, since it was the first time I dealt with the CRUD using the Devise's generated User model. It took me a couple of days to comprehend and create scoped routes.

### Continued development

I am aware that my solution is not complete (and that some solutions I offer are not considered 'elegant' (I'm looking at you Dashboard!). I think the main error in my case was that I hadn't planned in advance how I was going to use the CRUD pattern with the Devise users, having no other scaffolded model linked to the project. 

I will here list some solutions I had planned to work with to solve some of the features required by the challenge: 
- to differentiate between Admin and User, I had at first thought I'd use a method within the controller, but this was going to become very complex because I would have had to 'hide' some views from the User. I then considered the CanCan gem but I then ran into a number of errors because of the 'load_and_authorize_resource' command in the Controller;
- with regard to avatar upload from file, I intended to use Active_Storage;
- with regard to importation of a spreadsheet (XLS file) I intended to use the [roo gem](https://github.com/roo-rb/roo), for parsing;
- the .gitignore file would have been used to store the Cloudinary keys used for image optimisation;
- some UI React components could have been planned to be used for the admin toggle, or the dashboard, import progress bar.

### Useful resources

- [Devise Wiki](https://github.com/heartcombo/devise/wiki) - This helped me learn more about Devise. I am still learning some concepts but the documentation is very well-written and extensive. 

## Author

- Portfolio Website - Krista Calleja (https://kristacalleja.github.io/)

## Acknowledgments

I thank the Umanni HR Rep, L.M.A. who gave me the opportunity to offer proof of my skills and level of experience. I also thank the Umanni Tech Team who have offered a glimpse of their methodology and the interesting work they carry out.