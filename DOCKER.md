# How to install with Docker Compose

1) Clone this repo and its submodules using `git clone --recursive https://github.com/TeemuKoivisto/example-kubernetes-stack.git`.
2) Follow the directions in `my-reverse-proxy` to create your own local SSL-certificate.
3) Load the helper functions with `. functions.sh`. You can use them as eg. `rm-images my-node` or `rm-containers teemu`.
4) Build and start the stack with `docker-compose up`.
5) Seed the database: `./seed-db.sh docker`. It uses the `add_test_data.sql` file from the `my-node-bootstrap`.
6) And that's it! The app should be available at https://localhost:9443 (select "Trust this site" from options to bypass Chrome warnings)

# Using Docker Compose

Docker Compose is a mostly just a simple development set-up for running Docker-based stacks. You shouldn't use it in production.

Here's some useful commands with it:

* `docker-compose up` will launch the stack as a process that you can manually exit.
* `docker-compose -d up` will launch it as a daemon in a background.
* `docker-compose stop` will the stop the containers and `docker-compose start` restart them as daemon processes.
* `docker-compose up -d my_postgres_db` will launch only a one service.
* `docker-compose down` stops and removes all the containers of the stack.
* `docker-compose build` rebuilds the images specified as Dockerfiles in the `docker-compose.yml` (currently only my-reverse-proxy).

You can deploy your images to Docker Hub using:
```sh
docker login
docker build -t teemukoivisto/my-react-bootstrap:0.3.1 .
docker push teemukoivisto/my-react-bootstrap:0.3.1
```

## TODO

* Use local DNS for the localhost:9443 address with the entry in `/etc/hosts` (or not because that makes everything complicated)