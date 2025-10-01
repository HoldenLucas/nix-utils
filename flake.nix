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

      devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          scripts = self.lib.mkScripts pkgs (rec {
            test = "echo hello world";
          });
        in
        {
          default = pkgs.mkShell {
            packages = scripts;
          };
        }
      );
    };
}
