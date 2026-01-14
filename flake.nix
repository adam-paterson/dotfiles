{
  description = "Adam's Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    let
      meta = import ./meta.nix;
      lib = import ./lib { inherit inputs meta; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = meta.allSystems;

      perSystem =
        { pkgs, system, ... }:
        {
          formatter = pkgs.nixfmt;
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt
              nil
              statix
              deadnix
            ];
          };
        };

      flake = {
        # ── Darwin Hosts (macOS) ─────────────────────────────────────────────
        darwinConfigurations = {
          macbook = lib.mkDarwinHost { hostname = "macbook"; };
          macbook-intel = lib.mkDarwinHost { hostname = "macbook-intel"; };
        };

        # ── Home Configurations (Linux/Ubuntu/WSL) ───────────────────────────
        homeConfigurations = {
          "adampaterson@ubuntu-vps" = lib.mkHomeConfiguration { hostname = "ubuntu-vps"; };
          "adampaterson@wsl" = lib.mkHomeConfiguration { hostname = "wsl"; };
          "adampaterson@linux-arm" = lib.mkHomeConfiguration { hostname = "linux-arm"; };
        };
      };
    };
}
