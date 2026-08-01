# Home Assistant Add-ons

A small collection of Home Assistant add-ons.

## Installation

In Home Assistant, go to **Settings → Add-ons → Add-on store**, open the **⋮**
menu, choose **Repositories** and add:

```
https://github.com/dKemen/hassio-addons
```

The add-ons then show up in the store. They are built on your Home Assistant
machine on first install, so give that a few minutes.

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

## SparkyFitness

SparkyFitness is a self-hosted, privacy-friendly alternative to MyFitnessPal. It tracks nutrition, exercise, water, sleep, fasting, mood, body measurements, goals and check-ins, supports multiple users with family sharing, and integrates with Apple Health, Google Health Connect, Fitbit, Withings, Polar, Hevy, OpenFoodFacts, USDA, Nutritionix and Mealie.

Upstream ships SparkyFitness as three containers. This add-on runs the web frontend, the API server and its own PostgreSQL 18 server in a single container and initialises everything on first start, so there is nothing to configure before you start it. Install it, start it, then use the "OPEN WEB UI" button to register your account.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Does not support armv7 Architecture][armv7-no-shield]

### Configuration

Every option is optional; the add-on runs with its defaults. The ones most
people touch:

- `admin_email`: the account granted administrator privileges on each start.
  Register the account first, then set this.
- `disable_signup`: block further registrations once your accounts exist.
- `frontend_url`: only needed behind a reverse proxy. Otherwise it is derived
  from your Home Assistant host name.

The remaining options cover logging, CORS, SMTP and using an external
PostgreSQL server instead of the bundled one. They are documented, together
with backup behaviour and troubleshooting, in
[sparkyfitness/DOCS.md](sparkyfitness/DOCS.md) — which is also what Home
Assistant shows on the add-on's Documentation tab.

Note that SparkyFitness itself is not open source in the usual sense: its
licence allows personal, educational and nonprofit use but prohibits commercial
use without permission.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[armv7-no-shield]: https://img.shields.io/badge/armv7-no-red.svg
