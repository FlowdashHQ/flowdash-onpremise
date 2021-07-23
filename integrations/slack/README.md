# Set up your Slack integration

To use the Flowdash Slack integration, please follow these instructions:

1. Log into your org's Slack Workspace at https://api.slack.com
2. Go to "Your Apps" > "Create New App"
3. Choose "From an app manifest"
4. Select your workspace
5. Remove the sample manifest YAML. 
6. Take a look, in your editor, at the YAML from this directory in `./manifest.yml`
7. Replace "YOUR_ORGANIZATION" with your organization's name 
8. Replace the value in `oauth_config.redirect_urls` (`https://app.flowdash.com/integrations/slack`) with `https://<your-flowdash-domain>/integrations/slack`
9. Copy and paste the YAML that you've edited in the YAML manifest in the slack UI.
10. In your new app page under "Basic Information" > "App Credentials", you'll need `Client ID` and `Client Secret`
11. Set `SETTINGS__SLACK_INTEGRATION__CLIENT_ID` and `SETTINGS__SLACK_INTEGRATION__CLIENT_SECRET` environment variables on your servers.

*APTIBLE* (note the double escape of the period for client id)
e.g.
```bash
aptible config:set --app <app-slug> \
  SETTINGS__SLACK_INTEGRATION__CLIENT_ID=1234567\\.7654321 \ 
  SETTINGS__SLACK_INTEGRATION__CLIENT_SECRET=itsasecret
```

*HEROKU*
```bash
aptible config:set --app <app-slug> \
  SETTINGS__SLACK_INTEGRATION__CLIENT_ID=1234567\.7654321 \ 
  SETTINGS__SLACK_INTEGRATION__CLIENT_SECRET=itsasecret
```
12. Go to Flowdash > Workspace Settings > Integrations > Slack and connect :)
