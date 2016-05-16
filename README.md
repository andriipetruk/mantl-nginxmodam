#  MANTL-NGINXMODAM


## Deploy Docker container with Nginx 1.7.7 with mod  OpenAM

## Usage

#### How to deploy and run
```
1. git clone git@github.com:andriipetruk/mantl-nginxmodam.git
2. cd mantl-nginxmodam
3. docker build -t mantl-nginxmodam -f Dockerfile .
4. docker run  --env-file=conf/nginx.env  -v $PWD/conf:/root/conf --name mantl-nginxmodam -p 80:8080   -d mantl-nginxmodam 
```




