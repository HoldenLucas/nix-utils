{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, self, ... }:
    {
      lib = {
        mkScripts =
          pkgs: scripts:
          builtins.attrValues (
            builtins.mapAttrs (
              name: content:
              # NOTE `set -x` echos the command before its output
              #      `,` prefix for ergonomic tab completion
              #      `\` suffix allows combining with other scripts
              pkgs.writeShellScriptBin ",${name}" ''
                set -x
                ${content} \
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
