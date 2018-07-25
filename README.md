# docker-ark-server-tools
Docker container for hosting a ARK: Survival Evolved server, with ark-server-tools for management

### Run with
```
docker run -d --name ark-server 7778:7778/udp -p 27015:27015/udp -v /host/folder/path:/ark jacobpeddk/ark-server-tools:latest
```

And then to interract with it.
Simply run the following command, which will send you into a live terminal within the container:
```
docker exec -it ark-server bin/bash
```
