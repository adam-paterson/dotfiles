# ╭──────────────────────────────────────────────────────────╮
# │ Library Functions                                        │
# ╰──────────────────────────────────────────────────────────╯
#
# Helper functions for creating host and home configurations.
# Reduces boilerplate in flake.nix and provides consistent patterns.

{ inputs, meta }:
let
  inherit (inputs) nixpkgs darwin home-manager;

  # ── Platform Detection ───────────────────────────────────────────────────
  isDarwin = system: builtins.match ".*-darwin" system != null;
  isLinux = system: builtins.match ".*-linux" system != null;
  isAarch64 = system: builtins.match "aarch64-.*" system != null;
  isX86_64 = system: builtins.match "x86_64-.*" system != null;

  # ── Feature Detection ────────────────────────────────────────────────────
  hasFeature = hostConfig: feature: builtins.elem feature (hostConfig.features or [ ]);

  # ── Config Getters ───────────────────────────────────────────────────────
  getUser = userKey: meta.users.${userKey};
  getHost = hostname: meta.hosts.${hostname};

  # ── Platform Module Selection ────────────────────────────────────────────
  getPlatformModule =
    hostConfig:
    if hasFeature hostConfig "wsl" then
      ../modules/home/platforms/wsl.nix
    else if isLinux hostConfig.system then
      ../modules/home/platforms/linux.nix
    else
      ../modules/home/platforms/darwin.nix;

in
rec {
  # Export helpers for use in modules
  inherit
    isDarwin
    isLinux
    isAarch64
    isX86_64
    hasFeature
    getUser
    getHost
    ;

  # ── mkDarwinHost ─────────────────────────────────────────────────────────
  # Create a Darwin (macOS) host with integrated home-manager
  mkDarwinHost =
    { hostname }:
    let
      hostConfig = getHost hostname;
      userConfig = getUser hostConfig.user;
      inherit (hostConfig) system;
    in
    darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          meta
          hostname
          hostConfig
          userConfig
          ;
      };
      modules = [
        ../modules/darwin
        ../hosts/darwin/${hostname}.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit
                inputs
                meta
                hostname
                hostConfig
                userConfig
                ;
            };
            users.${userConfig.username} = {
              imports = [
                ../modules/home
                ../modules/home/platforms/darwin.nix
                ../modules/roles/${hostConfig.role}.nix
              ];
              home.stateVersion = meta.defaults.stateVersion;
            };
          };
        }
      ];
    };

  # ── mkHomeConfiguration ──────────────────────────────────────────────────
  # Create standalone home-manager configuration (for Linux/Ubuntu/WSL)
  mkHomeConfiguration =
    { hostname }:
    let
      hostConfig = getHost hostname;
      userConfig = getUser hostConfig.user;
      inherit (hostConfig) system;
      pkgs = import nixpkgs { inherit system; };
      platformModule = getPlatformModule hostConfig;
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit
          inputs
          meta
          hostname
          hostConfig
          userConfig
          ;
      };
      modules = [
        ../modules/home
        platformModule
        ../modules/roles/${hostConfig.role}.nix
        ../hosts/linux/${hostname}.nix
        {
          home = {
            inherit (userConfig) username;
            homeDirectory = userConfig.homeDirectory.linux;
            inherit (meta.defaults) stateVersion;
          };
        }
      ];
    };

  # ── Host Lists ───────────────────────────────────────────────────────────
  # Get all darwin hosts from meta
  darwinHosts = builtins.filter (name: isDarwin meta.hosts.${name}.system) (
    builtins.attrNames meta.hosts
  );

  # Get all linux hosts from meta
  linuxHosts = builtins.filter (name: isLinux meta.hosts.${name}.system) (
    builtins.attrNames meta.hosts
  );
}
