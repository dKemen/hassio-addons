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
