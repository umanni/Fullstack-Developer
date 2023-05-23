# UMANNI FULLSTACK

This project consists of creating a user management application as part of the company's contracting process. [Umanni](https://www.umanni.com.br/).

## Project Requirements
The requirements for the project is to have [Ruby](https://www.ruby-lang.org/pt/documentation/installation/) installed on the machine, since this project was developed using [Ruby on Rails](https://guides.rubyonrails.org/v5.0/getting_started.html#installing-rails), the [PostgreSQL](https://www.postgresql.org/download/) database and for the interface [Typescript](https://www.typescriptlang.org/download) was used with [React](https://react.dev/) framework and e [Ant Design](https://ant.design/docs/react/getting-started)

## Requirements Versions

* ruby 3.1.4p223 (2023-03-30 revision 957bb7cb81)
* PostgreSQL
* Rails 7.0.4.3
* Typescript 5.0.2
* React 18.2.0

## Acquiring the project
The easiest and recommended way to acquire this project is using [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). To do this, within your command line tool, navigate to the folder where you want to place the project and run: <code>git clone https://github.com/pedrohbcosta/umanni_test.git</code>. If you have ssh configured, the command is <code>git clone git@github.com:pedrohbcosta/umanni_test.git</code>. Or if you have the CLI configured, just run the command <code>gh repo clone pedrohbcosta/umanni_test</code>

With the project developed in two parts, access the <code>cd api</code> project folder and install the dependencies: <code>bundle install</code>, error occurs regarding the version of the **Sprockets**, dependency, just run the command: <code>bundle update</code> and then: <code>bundle install</code>. Right after <code>cd web</code> and install the dependencies: <code>npm install</code>.

## Creating the database
A script responsible for creating the development and test banks is available and must be executed with the command: <code>rails db:create</code>.

## Creating the tables
To create the database schema, just run the responsible script through the command: <code>rails db:migrate</code>.

## Running the Test Suit
The project was fully developed using TDD. To run the test suit run: <code>bundle exec rspec</code>

## Up the server
* If the previous steps were correctly performed, everything is ready to upload the server. Just run <code>rails s</code> and wait a few moments. With the server live, the API is available at: <code>localhost:3000</code>. 
* On the front-end, just run: <code>npm run dev</code> and the server will start at <code>localhost:5173</code>.

## Execution
If everything was done perfectly, the application will be ready for use.
