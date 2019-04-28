# TAO Docker installation
A docker image for TAO e-Assessment suite


## Build

$ docker build . -t local/tao:0.8

## Run

$ docker-compose up

Got to http://localhost/tao/


## Known Issues

1. Host Port may not be different other than *80* otherwise redirection errors will occur and the application is not found

2. PHP > 7.1 does not work at the moment (see https://github.com/oat-sa/tao-core/issues/2091)
