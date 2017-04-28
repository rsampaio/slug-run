#!/bin/bash

set -eo pipefail

if [[ "$APP_NAME" == "" ]]; then
	echo "APP_NAME variable missing"
	exit -1
fi

if [[ "$HEROKU_TOKEN" == "" ]]; then
	echo "HEROKU_TOKEN variable missing"
	exit -1
fi

HEROKU_API_URL=${HEROKU_API_URL:-https://api.heroku.com}

HEADER_ACCEPT="Accept: application/vnd.heroku+json; version=3"
HEADER_AUTH="Authorization: Bearer $HEROKU_TOKEN"
HEADER_RELEASES="Range: version ..; order=desc" # from CLI

SLUG_OUTPUT=/slug.tgz

function downloadSlug() {
  SLUG_ID=$(curl -H "$HEADER_ACCEPT" -H "$HEADER_AUTH" -H "$HEADER_RELEASES" $HEROKU_API_URL/apps/$APP_NAME/releases | jq --raw-output '.[0]|.slug.id')
  SLUG_URL=$(curl -H "$HEADER_ACCEPT" -H "$HEADER_AUTH" $HEROKU_API_URL/apps/$APP_NAME/slugs/$SLUG_ID | jq --raw-output '.blob.url')
  curl -o $SLUG_OUTPUT "$SLUG_URL"
}

function unpackSlug() {
  tar xf $SLUG_OUTPUT -C /
}

function startSlug() {
  export HOME=/app
  cd $HOME
  source .profile.d/*.sh
  PROCESS_TYPE=${PROCESS_TYPE:-web}
  if [[ "$ENV_FILE" != "" ]]; then
	WITH_ENV="-e ${ENV_FILE}"
  fi
  forego start $WITH_ENV $PROCESS_TYPE
}

downloadSlug
unpackSlug
startSlug
