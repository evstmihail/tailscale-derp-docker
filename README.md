# Tailscale DERP Docker

A simple Docker container to run your own [Tailscale DERP server](https://tailscale.com/kb/1118/custom-derp-servers/).

Based on the original [Tailscale-DERP-Docker](https://github.com/n0ptr/Tailscale-DERP-Docker) by [Liam Tietjens](https://github.com/n0ptr).

## How It Works

The container runs two components:

1. **Tailscale client** — connects the container to your tailnet as its own device
2. **DERP server** — with `--verify-clients` enabled, only devices in your tailnet can use it

Placing a DERP server geographically closer to your devices improves relay connection speeds. This is scalable — deploy on servers in different regions as needed.

## Quick Start

### 1. Configure environment

Create a `.env` file:

```env
TAILSCALE_DERP_HOSTNAME=derp.example.com
TAILSCALE_DERP_VERIFY_CLIENTS=true
TAILSCALE_DERP_CERTMODE=letsencrypt
TAILSCALE_AUTH_KEY=tskey-auth-xxxxx
```

> Ensure the hostname resolves correctly in DNS before starting — Let's Encrypt needs it for certificate issuance.

> Use a non-ephemeral auth key and disable key expiry on the device after it connects.

### 2. Open firewall ports

```
80/tcp    — HTTP (cert challenges)
443/tcp   — DERP traffic
3478/udp  — STUN
```

### 3. Start the container

```bash
docker compose up -d
```

### 4. Check logs

```bash
docker logs -f tailscale-derp
```

## Pre-built Image

A GitHub Actions workflow builds and publishes a new image every ~10 days with the latest Tailscale and DERP versions:

```
ghcr.io/evstmihail/tailscale-derp-docker:latest
```

The `docker-compose.yml` uses this image by default.

## Building Locally

```bash
docker build . -t tailscale-derp-docker:latest
```

Then update `docker-compose.yml` image to `tailscale-derp-docker:latest`.

## Tailscale ACL Configuration

Once the DERP server appears in your Tailscale admin console, add this to your ACL to route traffic through it:

```jsonc
"derpMap": {
    "OmitDefaultRegions": true,
    "Regions": {
        "900": {
            "RegionID":   900,
            "RegionCode": "myderp",
            "Nodes": [
                {
                    "Name":     "1",
                    "RegionID": 900,
                    "HostName": "derp.example.com",
                },
            ],
        },
    },
},
```

Set `"OmitDefaultRegions": false` if you want to keep Tailscale's default DERP servers as fallback.

More info: [Custom DERP Servers](https://tailscale.com/kb/1118/custom-derp-servers/)  
