## Run on Heroku

1. Create an app
2. Create a postgres db
3. Create a redis db
4. Set up your AWS bucket: https://github.com/FlowdashHQ/flowdash-onpremise#connect-to-your-aws-bucket
5. Set config variables

```bash
$ heroku config:set --app flowdash-app \
    DATABASE_URL=<pg-connection-string> \
    PORT=3000 \
    RAILS_FORCE_SSL=enabled \
    REDIS_HOST=redis \
    REDIS_URL=<redis-connection-string> \
    SECRET_KEY_BASE=$(openssl rand -hex 64) \
    SETTINGS__ATTR_ENCRYPTED_KEY=$(openssl rand -hex 32) \
    SETTINGS__AUTHENTICATION__GOOGLE=true \
    SETTINGS__AUTHENTICATION__USERNAME_PASSWORD=false \
    SETTINGS__AWS__ACCESS_KEY_ID=<your-aws-access-key-id> \
    SETTINGS__AWS__BUCKET=<your-aws-bucket> \
    SETTINGS__AWS__REGION=<your-aws-bucket-region> \
    SETTINGS__AWS__SECRET_ACCESS_KEY=<your-aws-bucket-secret-access-key> \
    SETTINGS__GOOGLE__OAUTH_CLIENT_ID=<clientid> \
    SETTINGS__GOOGLE__OAUTH_CLIENT_SECRET=<secret> \
    SETTINGS__HASHID_SALT=$(openssl rand -hex 32) \
    SETTINGS__HOST_URL=<your-fully-qualified-domain> \
    SETTINGS__ON_PREMISE_LICENSE_KEY=<your-license key> \
    SETTINGS__SMTP_ENABLED=false
```

See https://github.com/FlowdashHQ/flowdash-onpremise#optional-configuration for optional configuration of your app.

5. We recommend configuring your app to use Standard 2x dyno types for both web and worker processes. Standard More info on dyno types [here](https://devcenter.heroku.com/articles/dyno-types).
6. Build & push the images and release the containers like so

```bash
$ heroku container:login
$ docker login
$ heroku container:push --recursive --app <app-name>
$ heroku container:release web worker uiworker console --app <app-name>
```
