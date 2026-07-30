#!/usr/bin/env sh
set -e

# Validate required environment variables
for var in TAILSCALE_AUTH_KEY TAILSCALE_DERP_HOSTNAME TAILSCALE_DERP_CERTMODE TAILSCALE_DERP_VERIFY_CLIENTS; do
    eval val=\$$var
    if [ -z "$val" ]; then
        echo "ERROR: $var is not set" >&2
        exit 1
    fi
done

# Start tailscaled
/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state &

# Wait for tailscale to connect
/usr/bin/tailscale up --accept-routes=true --accept-dns=true --auth-key="$TAILSCALE_AUTH_KEY"

# Create certs directory
mkdir -p "/root/derper/$TAILSCALE_DERP_HOSTNAME"

# Start Tailscale DERP server (exec replaces shell so signals are forwarded)
exec /usr/local/bin/derper \
    --hostname="$TAILSCALE_DERP_HOSTNAME" \
    --bootstrap-dns-names="$TAILSCALE_DERP_HOSTNAME" \
    -certmode="$TAILSCALE_DERP_CERTMODE" \
    -certdir="/root/derper/$TAILSCALE_DERP_HOSTNAME" \
    --stun \
    --verify-clients="$TAILSCALE_DERP_VERIFY_CLIENTS"
