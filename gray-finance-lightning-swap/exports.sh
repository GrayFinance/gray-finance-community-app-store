#!/bin/bash

touch ${EXPORTS_APP_DIR}/.env
if [ ! -f "${EXPORTS_APP_DIR}/wallet.json" ]; then
    echo "{}" > "${EXPORTS_APP_DIR}/wallet.json"
fi

export $(grep -v '^#' ${EXPORTS_APP_DIR}/.env | xargs) >> /dev/null 2>&1 

export APP_LN_SWAP_BACKEND_IP=10.21.21.38
export APP_LN_SWAP_BACKEND_PORT=1536

export APP_LN_SWAP_FRONTEND_IP=10.21.21.65
export APP_LN_SWAP_FRONTEND_PORT=5173

# Redis configuration.
if [ -z ${REDIS_PASS+x} ]; then
    export REDIS_PASS="password"
fi

# Lnd configuration.
if [ -z ${LND_HOST+x} ]; then
    export LND_HOST="https://host.docker.internal:8080"
fi

if [ -z ${LND_MACAROON+x} ]; then
    export LND_MACAROON=$(sudo xxd -ps -u -c 1000 "$UMBREL_ROOT/app-data/lightning/data/lnd/data/chain/bitcoin/${APP_BITCOIN_NETWORK}/admin.macaroon")
fi

# Swap configuration.
if [ -z ${SWAP_SERVICE_FEERATE+x} ]; then
    export SWAP_SERVICE_FEERATE=0.5
fi

if [ -z ${SWAP_MIN_AMOUNT+x} ]; then
    export SWAP_MIN_AMOUNT=10000
fi

if [  -z ${SWAP_MAX_AMOUNT+x} ]; then
    export SWAP_MAX_AMOUNT=100000000
fi

export LNBITS_HOST="http://host.docker.internal:3007/api"
export LNBITS_BASE_URL="http://host.docker.internal:3007"
export LNBITS_WEBHOOK_URL="http://${APP_LN_SWAP_BACKEND_IP}:${APP_LN_SWAP_BACKEND_PORT}/api/v1/lnbits/webhook"

tor_hidden_service_path=("${EXPORTS_TOR_DATA_DIR}/app-${EXPORTS_APP_ID}/hostname")
if [ -f $tor_hidden_service_path ]; then
    if [ -z ${MIRRORS_TOR_URL+x} ]; then
        tor_hidden_service=$(cat $tor_hidden_service_path)
        echo "MIRRORS_TOR_URL=http://${tor_hidden_service}" >> ${EXPORTS_APP_DIR}/.env
        echo $tor_hidden_service > ${EXPORTS_APP_DIR}/tor.url
    fi
fi