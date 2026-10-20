# soju image

A container image of [soju](https://soju.im), the IRC bouncer, on Alpine. It is `docker.io/kenshaw/soju:latest`.

- `Containerfile` installs the Alpine package of soju (and `sojuctl`, `yq`) and runs soju as user 10001.
- `build.sh` builds and pushes `:latest`, `:<soju version>` and `:<date>`. `./build.sh --no-push` builds only.
- `systemd/` has a service and a timer that run `build.sh` every day at 04:00. `./install.sh` installs them as user units.

Once: `podman login docker.io`. To check the timer: `systemctl --user list-timers soju-image.timer` and `journalctl --user -u soju-image.service`.
