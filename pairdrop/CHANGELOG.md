# Changelog

## 1.11.2.1

- New `instance_name` option: renames the browser tab, the installed app and
  the About dialog. The Home Assistant sidebar entry is unaffected — that one
  is fixed in `config.yaml`.
- New `primary_color` option: replaces PairDrop's default accent colour in both
  light and dark mode, and the theme colour of the installed app.
- Both are applied by rewriting the served files from untouched copies on every
  start, so restarts and option changes cannot accumulate edits. The service
  worker's cache version now includes these settings, so a change takes effect
  immediately instead of being served from the old cache.

## 1.11.2

- Initial release, packaging PairDrop 1.11.2 (linuxserver.io build `ls142`).
- Available through the Home Assistant sidebar via Ingress, and on port 3000
  for devices without a Home Assistant login. Both routes share the same room,
  so devices see each other regardless of which one they used.
- Options for rate limiting, WebSocket fallback, debug logging, IPv6 grouping,
  an external signaling server and the time zone.
- No database, no volume, no state.
