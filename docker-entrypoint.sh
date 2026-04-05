#!/bin/bash
set -e

extract_mongo_host() {
  echo "$MONGO_URL" | sed -n 's|.*://\([^/:]*\).*|\1|p'
}

MONGO_HOST=$(extract_mongo_host)

if [ -z "$MONGO_HOST" ]; then
  echo "ERROR: Could not extract MongoDB host from MONGO_URL"
  exit 1
fi

echo "Waiting for MongoDB at $MONGO_HOST to accept connections..."
until mongosh --host "$MONGO_HOST" --eval "db.adminCommand('ping')" --quiet 2>/dev/null; do
  sleep 1
done
echo "MongoDB is reachable."

echo "Checking if replica set is initialized..."
RS_STATUS=$(mongosh --host "$MONGO_HOST" --quiet --eval "
  try {
    var s = rs.status();
    if (s.ok === 1) print('initialized');
    else print('error');
  } catch(e) {
    if (e.codeName === 'NotYetInitialized' || e.code === 94) print('not_initialized');
    else print('error');
  }
" 2>/dev/null)

if [ "$RS_STATUS" = "not_initialized" ]; then
  EXTRACTED_HOST="$MONGO_HOST:27017"
  echo "Initializing replica set rs0 with member $EXTRACTED_HOST..."
  mongosh --host "$MONGO_HOST" --quiet --eval "
    rs.initiate({
      _id: 'rs0',
      members: [
        { _id: 0, host: '$EXTRACTED_HOST' }
      ]
    })
  "

  echo "Waiting for primary election..."
  RETRIES=0
  MAX_RETRIES=60
  until [ "$RETRIES" -ge "$MAX_RETRIES" ]; do
    STATE=$(mongosh --host "$MONGO_HOST" --quiet --eval "
      try {
        var s = rs.status();
        var me = s.members.find(m => m.self === true);
        if (me) print(me.stateStr);
        else print('WAITING');
      } catch(e) { print('WAITING'); }
    " 2>/dev/null || echo "WAITING")

    if echo "$STATE" | grep -q "PRIMARY"; then
      echo "Primary elected. Replica set ready."
      break
    fi

    RETRIES=$((RETRIES + 1))
    sleep 1
  done

  if [ "$RETRIES" -ge "$MAX_RETRIES" ]; then
    echo "WARNING: Timed out waiting for primary election. Starting anyway."
  fi
else
  echo "Replica set already initialized (status: $RS_STATUS)."
fi

echo "Starting Rocket.Chat..."
exec "$@"
