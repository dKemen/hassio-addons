## Globalping

To update globalping:
- The add-on tracks `globalping/globalping-probe:latest` (see `globalping/build.yaml`).
- Bump `version` in `globalping/config.yaml` when releasing a new add-on version.

## SparkyFitness

The add-on builds on the upstream images and pins them to an exact release
rather than tracking `latest`.

To update to a new SparkyFitness release:
- Bump the tag in both places it appears: `SPARKYFITNESS_FRONTEND` and
  `BUILD_FROM` in `sparkyfitness/Dockerfile`, and `build_from` in
  `sparkyfitness/build.yaml`.
- Bump `version` in `sparkyfitness/config.yaml` to match, and add a
  `sparkyfitness/CHANGELOG.md` entry.
- Check the upstream release notes for new or renamed `SPARKY_FITNESS_*`
  environment variables and add options for anything users need. The variables
  are published in
  `sparkyfitness/rootfs/etc/s6-overlay/s6-rc.d/init-sparkyfitness/run`.
- Watch out for changes to `docker/nginx.conf` and `docker/docker-entrypoint.sh`
  upstream: the add-on copies both out of the frontend image instead of
  re-implementing them, and the entrypoint is what renders the nginx config.

If upstream bumps its PostgreSQL major version, bump `PG_MAJOR` in
`sparkyfitness/rootfs/etc/s6-overlay/s6-rc.d/init-postgres/run` and the
`postgresql18` package in `sparkyfitness/Dockerfile` together. Existing
installations then need a dump and reimport — the add-on detects the mismatch
and refuses to start rather than damaging the cluster.

Local checks (there is no CI in this repository):
- `shellcheck` over `sparkyfitness/rootfs/etc/s6-overlay/s6-rc.d/*/{run,finish}`
- `docker build -t sparkyfitness-test sparkyfitness/`

## PairDrop

The add-on wraps the linuxserver.io image, which is the maintained multi-arch
build — the upstream workflow only builds locally as a CI check and publishes
nothing.

To update:
- Find the newest tag and confirm it is multi-arch:
  ```
  TOKEN=$(curl -s "https://ghcr.io/token?scope=repository:linuxserver/pairdrop:pull&service=ghcr.io" | jq -r .token)
  curl -s -H "Authorization: Bearer $TOKEN" "https://ghcr.io/v2/linuxserver/pairdrop/tags/list?n=1000"
  ```
  Note that the tag list is paginated and sorted lexically, so `v1.11.x` comes
  before `v1.4.0` — sort by version, not by string.
- Bump the tag in `pairdrop/Dockerfile` (`BUILD_FROM`) and
  `pairdrop/build.yaml`, set `version` in `pairdrop/config.yaml` to the
  PairDrop version, and add a `pairdrop/CHANGELOG.md` entry.
- Check upstream `server/index.js` for new environment variables. Watch how
  each one is parsed: most are compared against the literal string `"true"`,
  but `RATE_LIMIT` also accepts a number, and `IPV6_LOCALIZE` goes through
  `parseInt`. Passing the wrong shape fails silently.

`pairdrop/run.sh` reads `/data/options.json` with `jq` and hands over to the
base image's s6 init with `exec /init`. It deliberately does not use bashio:
nothing here needs the Supervisor API.

Local checks:
- `shellcheck pairdrop/run.sh`
- `docker build -t pairdrop-test pairdrop/`
