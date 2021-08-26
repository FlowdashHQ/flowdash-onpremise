## Run on Heroku

1. Create an app
2. Create a postgres db
3. Create a redis db
4. Set config variables as described in the main README
5. Build & push the images and release the containers like so
```bash
$ heroku container:login
$ docker login
$ heroku container:push --recursive --app <app-name>
$ heroku container:release web worker uiworker --app <app-name>
```
