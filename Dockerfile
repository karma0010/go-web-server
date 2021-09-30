FROM golang:latest as builder
ENV GO111MODULE=on
ENV GOFLAGS=-mod=vendor
ENV APP_HOME /go/src/go-web-server
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
COPY ./go-web-server /go/src/go-web-server
WORKDIR $APP_HOME
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

#Use alpine for low footprint and security in a multistage
FROM alpine:latest  
RUN apk --no-cache add ca-certificates
RUN addgroup -S golang && adduser -S golang -G golang
ENV APP_HOME /go/src/go-web-server
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
# Copy the previous stage from builder 
COPY --from=builder $APP_HOME/main .
# Expose port 3030
EXPOSE 3030
USER golang
CMD ["./main"] 
