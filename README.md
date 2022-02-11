# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version

* Ruby [2.4.0]
* Rails [5.0.2]

- Check Dependencies
  Run on terminal

```bash
bundle
```

- Create and setup the database
  Run on terminal

```bash
rails dev:setup
```

This will drop, create and migrate the database tables

- Start the Rails server
  Run on terminal

```bash
rails s
```

Wait for the local server to come up and you can check the application at localhost:3000

- Import Users

To import users, it must be a csv file.

For example

```bash
user3@user.com;123456;123456;User3;;false
adm@adm.com;123456;123456;Admin;;true
```

Every ";" will register this information in the column of the User table
