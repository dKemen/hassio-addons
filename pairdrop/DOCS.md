# Home Assistant Add-on: PairDrop

Local file sharing in your browser — a self-hosted AirDrop alternative.

[PairDrop](https://github.com/schlagmichdoch/PairDrop) transfers files and text
directly between devices on your network using WebRTC. Nothing is uploaded to a
cloud service; the add-on only brokers the connection between the two devices.

The add-on stores no data at all: no database, no volume, no account. Install
it, start it, done.

## Installation

1. Add this repository to Home Assistant: **Settings → Add-ons → Add-on store
   → ⋮ → Repositories**, then enter
   `https://github.com/dKemen/hassio-addons`.
2. Find *PairDrop* in the store and select **Install**, then **Start**.
3. Open it from the Home Assistant sidebar.

## How devices find each other

PairDrop groups devices by IP address, and it treats every private address —
anything in your home network — as one and the same. That means **all your
devices end up in the same room automatically**, and it does not matter which
way they reached the add-on:

- through the **Home Assistant sidebar** (Ingress), or
- directly at **`http://<your-ha-host>:3000`**.

A phone opened through Ingress and a laptop opened on port 3000 will see each
other and can exchange files.

Both routes exist because they serve different needs. Ingress requires a Home
Assistant login, which is what you want for your own devices. A visitor's phone
has no such login, so it uses the direct port instead. If you would rather not
have the port open, set the port to *disabled* in the add-on's **Network**
section; the sidebar keeps working.

For devices on a different network there is no auto-discovery. Use the pairing
function in the PairDrop interface: one device shows a six-digit code, the other
enters it, and they stay paired afterwards.

## Configuration

The add-on works without any configuration. Every option below is optional.

### Option: `rate_limit`

Limits each client to a fixed number of requests per five minutes. Defaults to
`false`. Worth enabling only if you expose the add-on beyond your own network.

### Option: `ws_fallback`

Allows transfers to fall back to the WebSocket connection when a direct WebRTC
connection cannot be established. Defaults to `false`.

Enable this if devices see each other but transfers never start — some networks,
in particular guest or client-isolated Wi-Fi, block the direct peer connection.
Note that with the fallback active the file travels through the add-on instead
of directly between the devices, which is slower.

### Option: `debug_mode`

Logs the environment and the IP addresses of connected peers. Defaults to
`false`. Useful when devices do not discover each other.

### Option: `ipv6_localize` (optional)

Number of IPv6 hextets, `1` to `7`, used to group peers. Only relevant on
IPv6-only networks where devices have addresses that differ in the lower parts
and therefore do not land in the same room. Leave empty otherwise.

### Option: `signaling_server` (optional)

Use a different signaling server instead of this add-on. Only useful for special
setups; leave empty.

### Option: `timezone` (optional)

Time zone for the log timestamps, for example `Europe/Berlin`.

## Ports

| Port       | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| `3000/tcp` | Direct access for devices without a Home Assistant login.       |

## Troubleshooting

**Devices do not see each other.** They are probably not on the same network —
a guest Wi-Fi or a VPN is enough to separate them. Turn on `debug_mode` and
check the log: if the peers show different IP addresses, they really are in
different networks. Use the six-digit pairing instead.

**Devices see each other but the transfer never starts.** The direct connection
is being blocked. Enable `ws_fallback`.

**The sidebar panel stays empty.** Reload the page. If it persists, check the
add-on log for the PairDrop service having started.

## Support

For problems with the add-on itself, open an issue at
<https://github.com/dKemen/hassio-addons/issues>.

For PairDrop itself, see <https://github.com/schlagmichdoch/PairDrop>.

## License

The add-on packaging in this directory is published under the MIT license.

PairDrop is licensed under the GNU General Public License v3.0. The container
image is built and maintained by [linuxserver.io](https://www.linuxserver.io/).
`icon.png` and `logo.png` are scaled from the official PairDrop app icon and
remain the property of the PairDrop authors.
