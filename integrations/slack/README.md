# Set up your Slack integration

To use the Flowdash Slack integration, please follow these instructions:

1. Log into your org's Slack Workspace at https://api.slack.com
2. Go to "Your Apps" > "Create New App"
3. Choose "From an app manifest"
4. Select your workspace
5. Remove the sample manifest YAML. 
6. Take a look, in your editor, at the YAML from this directory in `./manifest.yml`
7. Replace "YOUR_ORGANIZATION" with your organization's name
8. Replace all occurrences of `https://app.flowdash.com/...` values with `https://<your-flowdash-domain>/...`
9. Copy and paste the YAML that you've edited in the YAML manifest in the slack UI.
10. In your new app page under "Basic Information" > "App Credentials", you'll need `Client ID`, `Client Secret`, and `Signing Secret`.
11. Set `SETTINGS__SLACK_INTEGRATION__CLIENT_ID`, `SETTINGS__SLACK_INTEGRATION__CLIENT_SECRET`, & `SETTINGS__SLACK_INTEGRATION__SIGNING_SECRET` environment variables on your servers.

*APTIBLE*
e.g.
```bash
aptible config:set --app <app-slug> \
  SETTINGS__SLACK_INTEGRATION__CLIENT_ID=1234567.7654321 \ 
  SETTINGS__SLACK_INTEGRATION__CLIENT_SECRET=itsasecret \
  SETTINGS__SLACK_INTEGRATION__SIGNING_SECRET=anothersecret
```

*HEROKU*
```bash
heroku config:set --app <app-slug> \
  SETTINGS__SLACK_INTEGRATION__CLIENT_ID=1234567.7654321 \ 
  SETTINGS__SLACK_INTEGRATION__CLIENT_SECRET=itsasecret \
  SETTINGS__SLACK_INTEGRATION__SIGNING_SECRET=anothersecret
```
12. Go to Flowdash > Workspace Settings > Integrations > Slack and connect :)

## Posting to private channels

To post messages to private channels, make sure to invite your bot to the private channel in Slack first. Once the bot has been added, the private channel should appear in the channels dropdown in Flowdash.
