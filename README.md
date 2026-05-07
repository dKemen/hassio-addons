Home Assistant Add-ons

## Globalping

Globalping is a free, open-source platform for network testing and monitoring. At its core is a robust API that can schedule and run network-related commands in real-time from any location in the world.

It's a simple and secure way to test your web services, APIs, CDNs, DNS and edge compute services, to ensure their global availability, and understand their latency and performance on a global scale.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armv7 Architecture][armv7-shield]

### Configuration

The add-on supports the following options:

- `adoption_token` (optional): your Globalping adoption token from
  https://dash.globalping.io/probes. When set, the probe is automatically
  adopted to your account on startup. Leave empty to fall back to the
  interactive adoption-code flow shown in the add-on logs.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
