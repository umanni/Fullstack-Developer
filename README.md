# Umanni - Full Stack Developer Test

This project was created for the Umanni Full Stack Developer test.

## Getting started

### Prerequisites

- Docker

### Running the project

We are using Docked Rails on the development, the new Rails official approach for Docker. Also, Rails 7.1 bring us a official Dockerfile to be used in production.

1. Clone the repository.
2. Navigate to the project directory.
3. Create the docker volume with `docker volume create ruby-bundle-cache`
4. Add the docked alias to your console with `alias docked='docker run --rm -it -v ${PWD}:/rails -v ruby-bundle-cache:/bundle -p 3000:3000 ghcr.io/rails/cli'`
5. Install Rails dependencies with `docked bundle install`
6. Install Node dependencies with `docked yarn install` or `docked npm install`
7. Run the server with `docked bin/dev`
8. Access http://localhost:3000
9. Migrate the database on the the browser

### Running without Docker

1. Clone the repository.
2. Navigate to the project directory.
3. Run `bundle install`
5. Run `npm install` or `yarn install`
4. Run `bin/dev`
5. Access http://localhost:3000
6. Migrate the database on the the browser

### Tech Stack

- Ruby on Rails 7.1 (alpha)
- Hotwire
- Tailwind CSS
- esbuild
- SQLite
- Docker