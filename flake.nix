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
      common = { pkgs, ... }: {
        imports = [
          droidspaces.nixosModules.working-droidspaces-rootfs-minimal
        ];

        networking.hostName = "droidnix";
        time.timeZone = "Asia/Jakarta";

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

        system.stateVersion = "25.11";
      };

      mk = nixpkgsInput: nixpkgsInput.lib.nixosSystem {
        inherit system;
        modules = [ common ];
      };
    in
    {
      nixosConfigurations = {
        # Varian modern
        droidnix = mk nixpkgs;
        # Kernel 5.4 ke bawah
        droidnix-old-kernel = mk nixpkgs-systemd259;
      };
    };
}
