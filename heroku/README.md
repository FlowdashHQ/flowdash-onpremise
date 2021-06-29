## Run on Heroku

1. Create an app
2. Create a postgres db
3. Create a redis db
4. Set config variables as described in the main README
5. We recommend configuring your app to use Standard 2x dyno types for both web and worker processes. More info on dyno types [here](https://devcenter.heroku.com/articles/dyno-types).
6. Build & push the images and release the containers like so
```bash
$ heroku container:login
$ docker login
$ heroku container:push --recursive --app <app-name>
$ heroku container:release web worker --app <app-name>
```
