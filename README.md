# Umanni - Full Stack Developer Test

This project was created for the Umanni Full Stack Developer test.

## Getting started

### Prerequisites

- Docker

### Running the project

We are using Docked Rails on the development, the new Rails official approach for Docker. Also, Rails 7.1 bring us a official Dockerfile.

1. Clone the repository.
2. Navigate to the project directory.
3. Create the docker volume with `docker volume create ruby-bundle-cache`
4. Add the docked alias to your console with `alias docked='docker run --rm -it -v ${PWD}:/rails -v ruby-bundle-cache:/bundle -p 3000:3000 ghcr.io/rails/cli'`
5. Run the server with `docked bin/dev`
6. Access http://localhost:3000/dashboard
7. Migrate the database on the the browser

### Running without Docker

1. Clone the repository.
2. Navigate to the project directory.
3. Run `bundle install`
4. Run `bin/dev`
5. Access http://localhost:3000/dashboard
6. Migrate the database on the the browser

### Tech Stack

- Ruby on Rails 7.1 (alpha)
- Hotwire
- Tailwind CSS
- esbuild