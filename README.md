# Flowdash On Premise

## Run Flowdash on Aptible

Check out the step by step video [here](https://www.loom.com/share/4b620b1b7bd14a34b6f71884bd51a0ee).  

1. Go to your Aptible dashboard and make sure you've added a public SSH key to your Aptible account.
2. Install the Aptible CLI and authenticate into your account.
3. Clone this repository. `git clone https://github.com/ReflowIQ/flowdash-onpremise.git`
4. Change your working directory `cd flowdash-onpremise`
5. If desired, update the `Dockerfile` with your desired version (replace `:latest` with a version tag)
6. Create a new app on Aptible `aptible apps:create <app-name>`
7. Add a postgres database `aptible db:create <db-name> --type postgresql --version 11`
8. Add a redis database `aptible db:create <db-name> --type redis --version 5.0`
9. Set your app config variables. Use these instructions to set `REDIS_URL` and `DATABASE_URL`: https://deploy-docs.aptible.com/docs/database-credentials#using-database-credentials
```bash
$ aptible config:set --app <app-slug> \
    APTIBLE_PRIVATE_REGISTRY_USERNAME=<username> \
    APTIBLE_PRIVATE_REGISTRY_PASSWORD=<pwd> \
    DATABASE_URL=<pg-connection-string> \
    REDIS_URL=<redis-connection-string> \
    SECRET_KEY_BASE=$(cat /dev/urandom | base64 | head -c 128) \
    SETTINGS__ATTR_ENCRYPTED_KEY=$(cat /dev/urandom | base64 | head -c 64) \
    SETTINGS__AUTHENTICATION__GOOGLE=true \
    SETTINGS__AUTHENTICATION__USERNAME_PASSWORD=true \
    SETTINGS__AWS__ACCESS_KEY_ID=<your-aws-access-key-id> \
    SETTINGS__AWS__BUCKET=<your-aws-bucket> \
    SETTINGS__AWS__REGION=<your-aws-bucket-region> \
    SETTINGS__AWS__SECRET_ACCESS_KEY=<your-aws-bucket-secret-access-key> \
    SETTINGS__GOOGLE__OAUTH_CLIENT_ID=<clientid> \
    SETTINGS__GOOGLE__OAUTH_CLIENT_SECRET=<secret> \
    SETTINGS__HASHID_SALT=$(cat /dev/urandom | base64 | head -c 64)	
```

### Database users

When you ran `aptible db:create <...>`, you created a postgres database with 2 users: `postgres` and `aptible`. 
In order to create the database, perform rollbacks, execute all migrations in future releases, maintain the Superuser role for the user you specified in your `DATABASE_URL` connection string.

You can verify which users are in your database by creating an ephemeral database tunnel `aptible db:tunnel <aptible-db-name>`.
```bash
$ aptible db:tunnel <aptible-db-name>
Creating postgresql tunnel to <aptible-db-name>...
Use --type TYPE to specify a tunnel type
Valid types for pg-dev: postgresql
Connect at postgresql://aptible:<password>@localhost.aptible.in:<port>/db
Or, use the following arguments:
* Host: localhost.aptible.in
* Port: <port>
* Username: aptible
* Password: <password>
* Database: db
Connected. Ctrl-C to close connection.
```
And in a separate terminal
```postgresql
$ psql postgresql://aptible:<password>@localhost.aptible.in:<port>/db
db=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 aptible   | Superuser                                                  | {}
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
```

You can create a new role if you so choose
```postgresql
db=# create user mynewrole;
CREATE ROLE
db=# alter user mynewrole with superuser;
ALTER ROLE
db=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 aptible   | Superuser                                                  | {}
 mynewrole | Superuser                                                  | {}
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
```

If you want to use `mynewrole`, you'll need to change the `DATABASE_URL` connection string.

### Connect to your AWS bucket:

You will need an s3 bucket, a User, and an IAM policy.
1. Create a new s3 bucket for Flowdash (e.g., `flowdash-data`)
2. Create a new User for Flowdash (e.g., `flowdash`) in your AWS IAM settings. Keep your access key ID and secret access key somewhere safe. Those should be used to set `SETTINGS__AWS__ACCESS_KEY_ID` and `SETTINGS__AWS__SECRET_ACCESS_KEY`, respectively 
3. Attach an s3 bucket policy with the following configuration
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::flowdash-data"
            ]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": [
                "arn:aws:s3:::flowdash-data/*"
            ]
        }
    ]
}
```

### Optional config settings:
```
# Clearbit
SETTINGS__CLEARBIT_TOKEN=<token>

# Email with SMTP
SETTINGS__SMTP_ENABLED=true
SETTINGS__SMTP_DOMAIN=<your-domain>
SETTINGS__SMTP_HOST=<your-smtp-host>
SETTINGS__SMTP_PASSWORD=<your-smtp-password>
SETTINGS__SMTP_PORT=<your-smtp-port>
SETTINGS__SMTP_USERNAME=<your-smtp-username>

# Google OAuth
SETTINGS__AUTHENTICATION__GOOGLE=true
SETTINGS__GOOGLE__OAUTH_CLIENT_ID=<clientid>
SETTINGS__GOOGLE__OAUTH_CLIENT_SECRET=<secret>
```

10. Add aptible as a remote and push
```
git remote add aptible git@beta.aptible.com/<aptible-environment>/<app-slug>.git
git push aptible master
```
11. Create an Aptible endpoint for `web`. **Make sure to set the container port to 8000**.
12. Set a new config variable
```
aptible config:set --app <app-slug> \ 
    SETTINGS__HOST_URL=<aptible-endpoint-host>
```

### Emails and new user sign ups
If you don't want to receive email, then beware that you can only add new users with Google. 
For that configuration, we suggest the following
```
SETTINGS__SMTP=disabled
SETTINGS__AUTHENTICATION__USERNAME_PASSWORD=false
SETTINGS__AUTHENTICATION__GOOGLE=true
SETTINGS__GOOGLE__OAUTH_CLIENT_ID=<clientid>
SETTINGS__GOOGLE__OAUTH_CLIENT_SECRET=<secret>
```
Please note that you will not receive emails, even those triggered by failures.

If you want your users to receive email, please provide valid smtp settings.
```
SETTINGS__AUTHENTICATION__USERNAME_PASSWORD=<true|false>
SETTINGS__HOST_URL=<aptible-endpoint-host>
SETTINGS__SMTP_ENABLED=true
SETTINGS__SMTP_DOMAIN=<your-domain>
SETTINGS__SMTP_HOST=<your-smtp-host>
SETTINGS__SMTP_PASSWORD=<your-smtp-password>
SETTINGS__SMTP_PORT=<your-smtp-port>
SETTINGS__SMTP_USERNAME=<your-smtp-username>
```
New user registrations through username/password (not Google) will need to verify their identity via email, which requires valid smtp settings.
Your `SETTINGS__HOST_URL` (Aptible endpoint) must also be set for email buttons to work properly.

### Google OAuth
To set up OAuth for your internal team, start by logging into your the the Google Cloud Platform for your team's workspace. Then, do the following
1. Create a new project
2. Go to `APIs and Services`
3. Create an `OAuth consent screen` and make it “internal”
4. Create a new `Credentials > OAuth client ID > web application`
5. Add `https://<yourdomain>` (from the endpoint creation step. should be the same as `SETTINGS__HOST_URL`) to "Authorized Javascript Origins"
6. Add `https://<yourdomain>/users/auth/google_oauth2/callback` to "Authorized redirect URIs"
7. Save
8. Back in your terminal, set
```bash
aptible config:set --app <app-name> SETTINGS__GOOGLE__OAUTH_CLIENT_ID=<new_client_id> SETTINGS__GOOGLE__OAUTH_CLIENT_SECRET=<new_client_secret>
```

### Public API Considerations
If you're running Flowdash on-premise on a private network (or something like Cloudflare zero trust), then you'll need to allow-list public API endpoints
to confinue using them without the request being blocked.
Our api routes are `/api/*`. For example, the cloud application API tasks route is `https://app.flowdash.com/api/v1/tasks` 
To permit future routes and versions, we suggest allow-listing `<your-domain>/api/*` routes.
More API documentation can be found [here](https://www.notion.so/Flowdash-API-Docs-13d77071206541898c97ca0ef95e8ce9#38a42c67eef943edada3dc39ff60d36d).
