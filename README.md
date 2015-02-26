Runs a (Mesos/Marathon) [Bamboo](https://github.com/QubitProducts/bamboo/) instance.

Available on the Docker Hub as [mbabineau/bamboo](https://registry.hub.docker.com/u/mbabineau/bamboo/):

    docker pull mbabineau/bamboo

### Versions
* Bamboo 0.2.4

### Usage
Starting the container:

    docker run -t -i --rm \
        -p 8000:8000 \
        -p 80:80 \
        -e MARATHON_ENDPOINT=<marathon_endpoint> \
        -e BAMBOO_ENDPOINT=<bamboo_endpoint> \
        -e BAMBOO_ZK_HOST=<zk_connect_string> \
        -e BAMBOO_ZK_PATH=/bamboo \
        mbabineau/bamboo \
            -bind=":8000"


(See Bamboo's [documentation](https://github.com/QubitProducts/bamboo/blob/master/README.md) for more details on running Bamboo as a Docker container)

Once the container is up, visit `http://<host>:8000/` and confirm Bamboo is running.
