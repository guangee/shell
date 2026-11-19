#!/bin/sh
# Mirrors backend/internal/ip_ranges.js — bake CDN IP ranges at image build time.
set -eu

OUT="/etc/nginx/conf.d/include/ip_ranges.conf"
TMP="${TMPDIR:-/tmp}/npm-ip-ranges.$$"
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT

fetch() {
	url="$1"
	dest="$2"
	echo "Fetching $url ..."
	# Optional: docker build --build-arg HTTPS_PROXY=http://host:7890
	proxy="${HTTPS_PROXY:-${HTTP_PROXY:-}}"
	if [ -n "$proxy" ]; then
		curl -fsSL -x "$proxy" --connect-timeout 30 --max-time 300 -o "$dest" "$url"
	else
		curl -fsSL --connect-timeout 30 --max-time 300 -o "$dest" "$url"
	fi
}

fetch "https://ip-ranges.amazonaws.com/ip-ranges.json" "$TMP/aws.json"
fetch "https://www.cloudflare.com/ips-v4" "$TMP/cf4.txt"
fetch "https://www.cloudflare.com/ips-v6" "$TMP/cf6.txt"

: >"$OUT"

jq -r '.prefixes[] | select(.service == "CLOUDFRONT") | .ip_prefix' "$TMP/aws.json" \
	| while read -r range; do [ -n "$range" ] && printf 'set_real_ip_from %s;\n' "$range"; done >>"$OUT"

jq -r '.ipv6_prefixes[]? | select(.service == "CLOUDFRONT") | .ipv6_prefix' "$TMP/aws.json" \
	| while read -r range; do [ -n "$range" ] && printf 'set_real_ip_from %s;\n' "$range"; done >>"$OUT"

grep -E '^([0-9]+\.){3}[0-9]+/[0-9]+$' "$TMP/cf4.txt" \
	| while read -r range; do printf 'set_real_ip_from %s;\n' "$range"; done >>"$OUT"

grep -E '^([0-9a-fA-F]+:)+/[0-9]+$' "$TMP/cf6.txt" \
	| while read -r range; do printf 'set_real_ip_from %s;\n' "$range"; done >>"$OUT"

count=$(grep -c '^set_real_ip_from' "$OUT" || true)
echo "Wrote $count set_real_ip_from entries to $OUT"
