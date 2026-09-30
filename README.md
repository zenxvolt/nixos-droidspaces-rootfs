# nixos-droidspaces-rootfs

Membangun rootfs NixOS (aarch64) untuk [Droidspaces](https://github.com/ravindu644/Droidspaces-OSS) lewat GitHub Actions.

Proyek ini tidak berafiliasi dengan proyek Droidspaces.

## Varian

| Varian | Untuk |
| --- | --- |
| `modern` | nixpkgs terbaru |
| `kernel-5.4-and-older` | nixpkgs yang di-pin ke systemd v259 (kernel 5.4 ke bawah) |

## Cara pakai

1. Buka tab **Actions** -> **Build NixOS rootfs for Droidspaces** -> **Run workflow**.
2. Pilih `variant`. Centang `publish` untuk membuat GitHub Release.
3. Unduh tarball, lalu pasang di Droidspaces lewat Containers -> "+" -> pilih tarball.

Login awal: user `user`, password `changeme`. Ganti segera dengan `passwd`.

## Membangun secara lokal

    nix build .#nixosConfigurations.droidnix.config.system.build.tarball
