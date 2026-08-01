# Changelog

## 1.6.0

- Initial release, packaging SparkyFitness v1.6.0.
- Runs the upstream frontend, API server and a bundled PostgreSQL 18 server in
  a single container under s6-overlay supervision.
- Initialises itself on first start: creates the database cluster, the database
  and its owner role, and generates the encryption key and session secret into
  `/data/secrets.json` so sessions survive restarts.
- Publishes the web interface on host port 3004 with an OPEN WEB UI button.
- Optional settings for administrator e-mail, registration lockout, SMTP and
  trusted origins.
- Optional external PostgreSQL server instead of the bundled one.
- Cold backups so the database cluster is archived consistently.
