# Builder

FROM golang:1.21

WORKDIR /workspace

# Install dependencies
COPY go.mod ./
RUN go mod download && go mod verify

# Build app
COPY main.go .
RUN go build -v -o executable ./...

# Runner

FROM bitnami/minideb

WORKDIR /app

RUN adduser --disabled-password --comment "" --no-create-home -u 2000 unprivileged
USER 2000
EXPOSE 8080
COPY --from=0 /workspace/executable .
COPY html html
CMD ["./executable"]
