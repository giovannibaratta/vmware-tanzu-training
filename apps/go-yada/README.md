# go-yada

<i>go-yada</i> is a simple HTTP server that serve a single path `/secrets`. When requests are made to this, the server will read the files in the directory specified by the environment variable `DIR_TO_MONITOR` and will print the content of the files to the HTTP response.

## How to build

```sh
docker build  -t giovannibaratta/go-yada .
```

> Add `--platform linux/amd64` or `--platform linux/arm64` to target amd64 or amr64 platform

```sh
docker push giovannibaratta/go-yada:latest
```