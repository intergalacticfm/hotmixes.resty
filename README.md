'content' is in stuff/

# build container

docker build -t hotmixesresty:0.1 .


# run container

docker container run --publish 8080:8080 hotmixesresty:0.1


# access container

http://localhost:8080
