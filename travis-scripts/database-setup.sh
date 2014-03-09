#! /usr/bin/env sh

SPEC_PATH="spec"
DUMMY_APP_PATH="$SPEC_PATH/dummy_app"

# on Rails 3, we need to explicitly initialize the test db
RAILS_MAJOR_VERSION=`rails -v | sed -e 's/[^0-9.]//g' -e 's/^\([[:digit:]]\)\..*/\1/g'`
echo -en "Rails major version: $RAILS_MAJOR_VERSION"
if [ "$RAILS_MAJOR_VERSION" == "3" ]; then
    echo -en "running migration"
    cd "$DUMMY_APP_PATH"
    rake db:migrate RAILS_ENV=test
else
    echo -en "skipping migration"
fi