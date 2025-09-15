{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    {
      lib = {
        mkScripts =
          pkgs: scriptsAttr:
          let
            scriptNames = builtins.attrNames scriptsAttr;
            scripts = scriptsAttr;
          in
          builtins.attrValues (
            builtins.mapAttrs (
              name: content:
              pkgs.writeShellScriptBin ",${name}" ''
                set -x
                ${content}
              ''
            ) scripts
          );
      };
    };
}
