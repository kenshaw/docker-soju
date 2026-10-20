# soju, the IRC bouncer, on Alpine. The packages are not pinned: the image is rebuilt every day (see systemd/), so it follows Alpine.
FROM docker.io/library/alpine:latest

# soju also ships `sojuctl`, which talks to the admin socket. yq reads the YAML files of a reconcile step.
RUN apk add --no-cache soju yq-go ca-certificates tzdata \
 && (deluser soju; delgroup soju; true) \
 && addgroup -g 10001 soju \
 && adduser -D -H -u 10001 -G soju soju \
 && mkdir -p /run/soju /etc/soju \
 && chown soju:soju /run/soju \
 && (chown -R soju:soju /var/lib/soju 2>/dev/null || true)

USER 10001:10001

# The config file is mounted at /etc/soju/soju.conf (it names the listen addresses, the TLS files and the database).
EXPOSE 6697
ENTRYPOINT ["soju", "-config", "/etc/soju/soju.conf"]
