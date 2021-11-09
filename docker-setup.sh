#!/bin/bash

postgresPassword=$(openssl rand -hex 32)
publicIpAddress=$(dig +short myip.opendns.com @resolver1.opendns.com)
secretKeyBase=$(openssl rand -hex 64)
encryptionKeyBase=$(openssl rand -hex 32)
hashIdSalt=$(openssl rand -hex 32)

echo "Hi! Let's set up a self-hosted Flowdash instance."
echo
echo "Quick question: Do you have a fully qualified domain pointed at your Flowdash server?"
echo
echo "If you have just created a new cloud server in previous steps, now is a good time to point your fully qualified domain to your server's public address."
echo
echo "Please type your fully qualified domain below. Press enter to skip."
read -p "Enter it here: (default is your public ip address: ${publicIpAddress}) " hostname

if [ -z "$hostname" ]; then
  hostname=$publicIpAddress
fi

if [ -f ./docker.env ]; then
  mv docker.env docker.env.$(date +"%Y-%m-%d_%H-%M-%S")
fi
touch docker.env

echo '## Set postgres connection string' >> docker.env
echo "DATABASE_URL=postgresql://postgres:${postgresPassword}@db:5432/flowdash_production" >> docker.env
echo "POSTGRES_PASSWORD=${postgresPassword}" >> docker.env
echo '' >> docker.env

echo '## Set redis connection string' >> docker.env
echo "REDIS_HOST=redis" >> docker.env
echo "REDIS_URL=redis://redis:6379/1" >> docker.env
echo '' >> docker.env

echo '## Set secrets' >> docker.env
echo "SECRET_KEY_BASE=${secretKeyBase}" >> docker.env
echo "SETTINGS__ATTR_ENCRYPTED_KEY=${encryptionKeyBase}" >> docker.env
echo "SETTINGS__HASHID_SALT=${hashIdSalt}" >> docker.env
echo '' >> docker.env

echo "## Set miscellaneous config" >> docker.env
echo "SETTINGS__AUTHENTICATION__GOOGLE=true" >> docker.env
echo "SETTINGS__AUTHENTICATION__USERNAME_PASSWORD=false" >> docker.env
echo "RAILS_FORCE_SSL=disabled" >> docker.env
echo "PORT=3000" >> docker.env
echo "SETTINGS__HOST_URL=${hostname}" >> docker.env
echo "SETTINGS__SMTP_ENABLED=false" >> docker.env
echo '' >> docker.env

echo "## Set S3 bucket settings" >> docker.env
echo "SETTINGS__AWS__ACCESS_KEY_ID=YOUR-ID" >> docker.env
echo "SETTINGS__AWS__BUCKET=YOUR-BUCKET" >> docker.env
echo "SETTINGS__AWS__REGION=YOUR-REGION" >> docker.env
echo "SETTINGS__AWS__SECRET_ACCESS_KEY=YOUR-SECRET-ACCESS-KEY" >> docker.env
echo '' >> docker.env

echo "## Google SSO configuration" >> docker.env
echo "SETTINGS__GOOGLE__OAUTH_CLIENT_ID=YOUR-GOOGLE-CLIENT-ID" >> docker.env
echo "SETTINGS__GOOGLE__OAUTH_CLIENT_SECRET=YOUR-GOOGLE-CLIENT-SECRET" >> docker.env
echo '' >> docker.env

echo '## License key' >> docker.env
echo 'SETTINGS__ON_PREMISE_LICENSE_KEY=EXPIRED-LICENSE-KEY-TRIAL' >> docker.env
echo '' >> docker.env

echo "Cool! Now add your license key, google SSO, and s3 variables in docker.env then run docker compose up to launch Flowdash."
