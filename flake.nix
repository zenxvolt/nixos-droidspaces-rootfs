{
  description = "Custom NixOS rootfs for Droidspaces (aarch64)";

  inputs = {
    # Varian modern (nixpkgs terbaru). Kalau kernel 5.4 ke bawah, pakai varian di bawah
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Kernel 5.4 ke bawah: nixpkgs yang di-pin ke systemd v259
    # (commit ini diambil dari dokumentasi resmi Droidspaces)
    nixpkgs-systemd259.url = "github:NixOS/nixpkgs/b86751bc4085f48661017fa226dee99fab6c651b";

    droidspaces.url = "github:ravindu644/Droidspaces-OSS";
  };

  outputs = { self, nixpkgs, nixpkgs-systemd259, droidspaces, ... }:
    let
      system = "aarch64-linux";

      # Konfigurasi bersama untuk kedua varian
      common = { pkgs, lib, ... }: {
        imports = [
          droidspaces.nixosModules.working-droidspaces-rootfs-minimal
        ];

        networking.hostName = lib.mkDefault "droidnix";
        time.timeZone = lib.mkDefault "Asia/Jakarta";

        # GANTI password ini setelah login pertama (passwd)
        users.users.user = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          initialPassword = "changeme";
        };

        environment.systemPackages = with pkgs; [
          git
          curl
          vim
          htop
        ];

        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        # mkDefault: modul Droidspaces sudah mengatur stateVersion sendiri ("26.05"),
        # jadi nilai dari modul yang dipakai dan tidak terjadi konflik.
        system.stateVersion = lib.mkDefault "25.11";
      };

      # Kompatibilitas untuk nixpkgs yang di-pin (varian kernel lama).
      # Modul Droidspaces terbaru memakai `services.journald.settings`, opsi
      # yang belum ada di nixpkgs hasil pin. Opsi ini kita definisikan sendiri
      # dan diteruskan ke `extraConfig` (hanya section [Journal] yang didukung).
      journaldSettingsShim = { lib, config, ... }:
        let
          fmt = v:
            if builtins.isBool v then (if v then "yes" else "no")
            else if builtins.isList v then lib.concatStringsSep " " (map toString v)
            else toString v;
        in
        {
          options.services.journald.settings = lib.mkOption {
            type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
            default = { };
          };
          config.services.journald.extraConfig = lib.concatStringsSep "\n" (
            lib.mapAttrsToList (k: v: "${k}=${fmt v}")
              (config.services.journald.settings.Journal or { })
          );
        };

      mk = nixpkgsInput: extraModules: nixpkgsInput.lib.nixosSystem {
        inherit system;
        modules = [ common ] ++ extraModules;
      };
    in
    {
      nixosConfigurations = {
        # Varian modern
        droidnix = mk nixpkgs [ ];
        # Kernel 5.4 ke bawah
        droidnix-old-kernel = mk nixpkgs-systemd259 [ journaldSettingsShim ];
      };
    };
}
