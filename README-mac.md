# Testing in docker on Mac

Find out the user ID of the user running docker inside the boot2docker or
dockermachine:
```sh
id -u
```

Enter the docker container with:
```sh
DOCKER_USER_ID=<UID> make docker-run
```
