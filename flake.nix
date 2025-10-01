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
              # NOTE `set -x` show the commands
              #      `,` prefix = better tab completion
              #      `\` suffix = optionally extend options :^)
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
            test-hello = "echo hello";
            test-compare = ''
              # NOTE these both work, first one is better!
              ${test-hello}
              ,test-hello
            '';
            test-extend = "${test-hello} hi hello!! wow!";
            test-multiline = ''
              echo hello
              echo world
            '';
            test-oneshot = ''
              ${pkgs.lib.getExe pkgs.neofetch}
            '';
            date = "date";
            test-extend-options = ''
              # NOTE call it like this...
              ${date}
              # NOTE or extend! useful!
              ${date} \
              --iso
            '';
            test = ''
              ${test-hello}
              ${test-compare}
              ${test-extend}
              ${test-multiline}
              ${test-oneshot}
              ${test-extend-options}
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
