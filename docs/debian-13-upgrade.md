# Upgrade the Yii website host to Debian 13

This is an in-place upgrade of `site.yii.c.cebe.net`, currently on Debian 11 Bullseye. Upgrade to Debian 12 Bookworm, reboot and verify the host, then repeat for Debian 13 Trixie. Follow the Debian release notes for each hop and its release-specific prompts. [Bullseye to Bookworm](https://www.debian.org/releases/bookworm/amd64/release-notes/ch-upgrading.html) · [Bookworm to Trixie](https://www.debian.org/releases/trixie/release-notes/upgrading.en.html)

## Before the window

1. Open the provider recovery console and verify you can log in as root and reboot or restore the machine. Take a restorable host snapshot and keep off-host backups of the MariaDB databases, application data and local configuration, Elasticsearch data or snapshots, and TLS material. Record how to restore them.
2. Record the running kernel, active services, PHP-FPM socket, APT sources and pins, held packages, and the health of the website, database, search, and queue. Check free space on `/`, `/boot`, and `/var`. Bring the current Debian release to its latest point release and resolve any package audit or dependency errors before changing suites.
3. Stage the helper from this repository. This Salt state installs only the helper and is separate from the regular website apply.

   ```sh
   docker compose run --rm -T ct salt-ssh 'site.yii.c.cebe.net' state.apply debian-upgrade
   ```

## Run each hop from the recovery console

1. Export `target=bookworm` for the first hop and `target=trixie` for the second. Use a persistent terminal session and record the session with `script -a "/root/debian-$target-upgrade.log"`.
2. Back up the current APT configuration. Review `/etc/apt/sources.list`, the files under `/etc/apt/sources.list.d/`, and any APT pins. Disable old-suite and third-party entries, including Sury PHP, nginx.org, and the Elasticsearch repositories, for the Debian package transaction. Keep their backed-up definitions for review after the upgrade. Set the Debian main, updates, and security sources to the target codename. Retain any Debian components the host actually uses. For example, the base Debian sources are:

   ```text
   deb https://deb.debian.org/debian <target> main
   deb https://deb.debian.org/debian <target>-updates main
   deb https://security.debian.org/debian-security <target>-security main
   ```

3. Refresh the indexes and review the proposed changes. The helper checks that the active package indexes come from the target Debian suite. Stop if the plan would remove a required service or the host's boot, network, or SSH packages without an understood replacement.

   ```sh
   yii-debian-upgrade "$target" plan
   ```

4. Run the minimal upgrade, review the updated full-upgrade plan, then run the full upgrade. APT prompts for package and configuration changes. Resolve any interrupted package operation before continuing, following the release notes.

   ```sh
   yii-debian-upgrade "$target" minimal
   yii-debian-upgrade "$target" plan
   yii-debian-upgrade "$target" full
   dpkg --audit
   apt-get check
   ```

5. Verify that the target kernel is installed and the bootloader is ready before rebooting from the console. After reboot, check `/etc/os-release`, `uname -r`, `systemctl --failed`, and SSH access from another session. Verify Nginx, the PHP-FPM socket, MariaDB, Elasticsearch, the queue, and an HTTPS request against the site. Resolve failures before the next hop. If recovery fails, restore the snapshot from the provider console.

## After Trixie boots

- Review the saved third-party repositories individually. Re-enable only sources suitable for Trixie and refresh APT. In particular, review the Elasticsearch package and index compatibility before replacing its repository or rebuilding any indexes.
- Validate the website Salt state in test mode before applying it. The current base tools state selects the legacy `python` package on Trixie, and the Elasticsearch state falls back to its legacy 2.x repository and Java 7. Resolve those selections before the full apply. Once the application state can apply cleanly, verify PHP 8.5 CLI and FPM, Nginx mainline 1.31.9 or newer, the TLS hosts and image proxy, the database, search, and queue before closing the window.
