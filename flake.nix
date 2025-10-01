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
          # NOTE use it like this
          scripts = self.lib.mkScripts pkgs (rec {
            test-hello = "echo this is a test";
            test-extend = "${test-hello}!! Wow!";
            test-multiline = ''
              echo hello
              echo world
            '';
            test = ''
              ,test-hello
              ,test-extend
              ,test-multiline
            '';
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
