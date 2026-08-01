# Changelog

## 1.11.2

- Initial release, packaging PairDrop 1.11.2 (linuxserver.io build `ls142`).
- Available through the Home Assistant sidebar via Ingress, and on port 3000
  for devices without a Home Assistant login. Both routes share the same room,
  so devices see each other regardless of which one they used.
- Options for rate limiting, WebSocket fallback, debug logging, IPv6 grouping,
  an external signaling server and the time zone.
- No database, no volume, no state.
