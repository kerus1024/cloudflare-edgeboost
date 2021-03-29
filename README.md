# CloudFlare Edge Boost
Force the edge region of the CloudFlare CDN to the Specific Region. (CLIENT)

### Dependencies
- Linux 3.4 or later
- `whois` utility
- `curl`

### How to use
1. Run `findtarget.bash` to find cloudflare cdn ips. this action will be generated cidr list file.
2. Run `gentables.bash` to install iptables filters.