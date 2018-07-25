# docker-ark-server-tools
Docker container for hosting a ARK: Survival Evolved server, with ark-server-tools for management

## Run
Run the container with the following command.
Remember to change the host path, to fit where you want it to store its data on the host machine.
```
docker run -d --name ark-server 7778:7778/udp -p 27015:27015/udp -v /host/folder/path:/ark jacobpeddk/ark-server-tools:latest
```

And then to interract with it.
Simply run the following command, which will send you into a live terminal within the container:
```
docker exec -it ark-server bin/bash
```

## Build
open terminal and cd to the folder where you've cloned the repository to.
Then run the following command:
```
docker build -t ark-game-server -f Dockerfile .
```
Afterwards you can run it just like up in the Run section. But instead of the layer name being:  
`jacobpeddk/ark-server-tools:latest`  
Now it's just:  
`ark-game-server`

### Example:
```
docker run -d --name ark-server 7778:7778/udp -p 27015:27015/udp -v /host/folder/path:/ark ark-game-server
```

If you want to follow along with the log output, you can run it as interractive with `-it` instead of `-d`:
```
docker run --rm -it --name ark-server 7778:7778/udp -p 27015:27015/udp -v /host/folder/path:/ark ark-game-server
```
Note the `--rm` part in above command, will make the container delete itself the moment you exit it.
