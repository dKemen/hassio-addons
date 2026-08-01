# Home Assistant Add-on: SparkyFitness

Self-hosted nutrition, exercise and health tracking — a privacy-friendly
MyFitnessPal alternative.

[SparkyFitness](https://github.com/CodeWithCJ/SparkyFitness) tracks nutrition,
exercise, water, sleep, fasting, mood, body measurements, goals and check-ins,
supports multiple users with family sharing, and integrates with Apple Health,
Google Health Connect, Fitbit, Withings, Polar, Hevy, OpenFoodFacts, USDA,
Nutritionix and Mealie.

Upstream ships SparkyFitness as three containers (web frontend, API server and
PostgreSQL). A Home Assistant add-on is always a single container, so this
add-on runs all three processes under s6 supervision and brings its own
PostgreSQL server. Nothing has to be configured before the first start.

## Installation

1. Add this repository to Home Assistant: **Settings → Add-ons → Add-on store
   → ⋮ → Repositories**, then enter
   `https://github.com/dKemen/hassio-addons`.
2. Find *SparkyFitness* in the store and select **Install**. The image is built
   on your Home Assistant machine, which takes a few minutes.
3. Select **Start**. The first start initialises the database, so give it a
   minute and watch the **Log** tab.
4. Select **OPEN WEB UI** and register your account.

The add-on works with its defaults. You only need the configuration below for
optional features or for reaching it through a reverse proxy.

## First start

On the very first start the add-on:

- generates the encryption key and the session secret and stores them in
  `/data/secrets.json`,
- creates a PostgreSQL 18 cluster in `/data/postgresql`,
- creates the database and its owner role,
- lets the server apply all database migrations and row level security
  policies.

Registration is open by default so you can create the first account. Afterwards
set `admin_email` to that account's address to gain access to the admin panel,
and enable `disable_signup` to stop further registrations.

## Accessing the web interface

The interface is published on port `3004` of your Home Assistant host, and the
**OPEN WEB UI** button on the add-on page opens it.

SparkyFitness cannot be embedded through Home Assistant Ingress: its frontend
bundle, its authentication client and its router all hard-code root-absolute
paths, so it cannot be served from a sub-path. To reach it from the sidebar
anyway, add it as a webpage:

1. Open a dashboard, select **Edit**, then **Add card → Webpage**.
2. Set the URL to `http://homeassistant.local:3004` (use your own host name
   or IP address).

## Configuration

Example configuration:

```yaml
log_level: INFO
allow_private_network_cors: true
disable_signup: true
force_email_login: true
public_api_docs: false
admin_email: you@example.com
frontend_url: https://fitness.example.com
```

### Option: `log_level`

How much detail the SparkyFitness server writes to the add-on log. One of
`DEBUG`, `INFO`, `WARN` or `ERROR`. Defaults to `INFO`.

### Option: `allow_private_network_cors`

Accept requests originating from private network addresses, and drop the
`Secure` flag from session cookies. Defaults to `true`, which is what makes
logging in over plain HTTP on your LAN work at all. Only turn this off when you
reach SparkyFitness exclusively over HTTPS.

### Option: `disable_signup`

Blocks new account registrations. Defaults to `false` so you can create your
first account; turn it on afterwards.

### Option: `force_email_login`

Keeps e-mail and password login available no matter what is configured in the
app. Defaults to `true`. This is a fail-safe: leave it on unless you have a
working OIDC setup, otherwise a misconfiguration can lock you out.

### Option: `public_api_docs`

Serves the Swagger API documentation at `/api/api-docs` without a login.
Defaults to `false`.

### Option: `frontend_url` (optional)

The address you use to reach SparkyFitness, for example
`https://fitness.example.com`. It drives the CORS allow list, the
authentication base URL and the passkey relying party ID.

Leave it empty and the add-on derives `http://<your-ha-hostname>.local:3004`
from Home Assistant. **Set it explicitly when you put SparkyFitness behind a
reverse proxy**, otherwise logins will be rejected.

### Option: `extra_trusted_origins` (optional)

Comma-separated list of additional addresses allowed to talk to the server, for
example `http://192.168.1.10:3004,http://nas.local:3004`.

### Option: `admin_email` (optional)

The account with this e-mail address is granted administrator privileges every
time the add-on starts. Register the account first, then set this option.

### Option: `timezone` (optional)

Time zone used by the server and the bundled database, for example
`Europe/Berlin`. Leave empty to use the Home Assistant system time zone.

### Options: `email_host`, `email_port`, `email_secure`, `email_user`, `email_password`, `email_from` (optional)

SMTP settings for outgoing mail, which SparkyFitness uses for password reset
messages. Leave `email_host` empty to keep e-mail disabled. `email_port`
defaults to `587`; enable `email_secure` for implicit TLS, usually on port
`465`.

### Options: `database_host`, `database_port`, `database_name`, `database_user`, `database_password` (optional)

Leave these empty — the default — and the add-on uses its own bundled
PostgreSQL server, which needs no configuration at all.

Set `database_host` only if you want to run SparkyFitness against your own
PostgreSQL server. In that case the bundled server stays idle and you have to
prepare the external one yourself:

- PostgreSQL 13 or newer; upstream tests against 18. No extensions are needed.
- The database named in `database_name` must already exist.
- The role in `database_user` must own that database and hold the `CREATEROLE`
  privilege, because the server creates its own limited application role during
  migration.
- `database_password` is required as soon as `database_host` is set.

Migrations still run automatically against the external database.

## Data and backups

Everything persistent lives in the add-on's `/data` directory, which Home
Assistant includes in its backups:

| Path               | Contents                                          |
| ------------------ | ------------------------------------------------- |
| `postgresql/`      | The bundled PostgreSQL cluster                    |
| `secrets.json`     | Generated encryption key and session secret       |
| `uploads/`         | Profile pictures and exercise images              |
| `backup/`          | Backups created from inside SparkyFitness         |

This add-on uses **cold backups**: Home Assistant stops it before taking a
snapshot and starts it again afterwards. That short interruption is deliberate,
because it is the only way to archive a running database cluster in a
consistent state.

Two consequences worth knowing:

- **Keep `secrets.json`.** If the session secret is lost, everyone is logged
  out; if it changes after someone enabled two-factor authentication, that
  account can no longer be accessed. If the encryption key is lost, stored
  credentials for third-party services have to be entered again.
- **The bundled PostgreSQL major version is pinned.** If a future add-on
  version ships a newer PostgreSQL, it refuses to start on an older cluster and
  says so in the log rather than risking your data.

## Ports

| Port     | Description                                                  |
| -------- | ------------------------------------------------------------ |
| `80/tcp` | The web interface, published on host port `3004` by default. |

The bundled PostgreSQL server listens on the container's loopback interface and
a unix socket only. It is never reachable from your network.

## Troubleshooting

Check the **Log** tab first. A healthy start logs, in this order: the generated
configuration, the PostgreSQL cluster becoming ready, the server applying
migrations, and finally the web interface starting.

**The add-on keeps restarting.** One of the supervised processes is failing; the
log names which one and its exit code. If PostgreSQL reports a version
mismatch, see the note about major versions above.

**Login fails or the page reports a CORS error.** The address in your browser
does not match what the server trusts. Set `frontend_url` to the exact address
you use, or add it to `extra_trusted_origins`. When accessing over plain HTTP,
`allow_private_network_cors` has to stay enabled.

**Everyone was logged out after a restart.** `/data/secrets.json` was removed or
replaced. It is regenerated automatically, but existing sessions cannot be
recovered.

## Support

For problems with the add-on itself, open an issue at
<https://github.com/dKemen/hassio-addons/issues>.

For questions about SparkyFitness, see the upstream project at
<https://github.com/CodeWithCJ/SparkyFitness> and its documentation at
<https://codewithcj.github.io/SparkyFitness/>.

## License

The add-on packaging in this directory is published under the MIT license.

`icon.png` and `logo.png` are the official SparkyFitness artwork, scaled from
`SparkyFitnessMobile/assets/images/logo.png` in the upstream repository, and
remain the property of its author.

SparkyFitness itself is **not** MIT licensed. It is distributed by its author
under a custom license that permits personal, educational and nonprofit use but
**prohibits commercial use without written permission**. Running this add-on at
home is covered; using it in a commercial context is not. Read the terms at
<https://github.com/CodeWithCJ/SparkyFitness/blob/main/LICENSE> before
deploying it anywhere revenue-generating.
