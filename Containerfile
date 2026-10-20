# soju, the IRC bouncer, on Alpine edge: the stable releases of Alpine have soju 0.10.1, and edge has 0.11.x (the version on the old server z01).
# The packages are not pinned: the image is rebuilt every day (see systemd/), so it follows Alpine edge.
FROM docker.io/library/alpine:edge

# soju also ships `sojuctl`, which talks to the admin socket. yq and psql are for the reconcile step in the cluster (xoxo-infra, clusters/apps/manifests/soju/reconcile.sh).
RUN apk add --no-cache soju yq-go postgresql-client ca-certificates tzdata \
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
