# ╭──────────────────────────────────────────────────────────╮
# │ Package Overlays                                         │
# ╰──────────────────────────────────────────────────────────╯
#
# Custom overlays to modify or add packages.

_final: _prev: {
  # Example: override a package
  # my-package = prev.my-package.overrideAttrs (old: {
  #   version = "1.0.0";
  # });

  # Example: add a custom package
  # my-custom-pkg = final.callPackage ../pkgs/my-custom-pkg { };
}
