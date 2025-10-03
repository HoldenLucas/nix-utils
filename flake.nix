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
              pkgs.writeShellScriptBin ",${name}" ''
                set -x
                ${content}
              ''
            ) scripts
          );

        # NOTE good for multiline scripts ( ''foo'' = multi, "foo" = single )
        extend = content: nixpkgs.lib.strings.removeSuffix "\n" content;
      };

      devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          scripts = self.lib.mkScripts pkgs (rec {
            test-hello = "echo hello";
            test-hello-multiline = ''
              echo hello
            '';
            test-compare = ''
              # NOTE both forms work!
              ${test-hello}
              # NOTE better for `mproc ",foo" ",bar"`!
              ,test-hello
            '';
            # NOTE single line scripts inline easy!
            test-extend = "${test-hello} hi hello!! wow!";
            # NOTE multi line scripts need self.lib.extend!
            test-extend-multiline = "${self.lib.extend test-hello-multiline} hi hello!! wow!";
            # NOTE this won't work!
            test-extend-multiline-broken = "${test-hello-multiline} hi hello!! wow!";
            test-multiline = ''
              echo hello
              echo world
            '';
            test-oneshot = ''
              ${pkgs.lib.getExe pkgs.neofetch}
            '';
            date = ''
              date
            '';
            date-utc = ''
              date --utc
            '';
            test-extend-options = ''
              # NOTE like this...
              ${date}
              # NOTE or extend options! useful!
              ${self.lib.extend date} \
              --iso
              ${date-utc}
              ${self.lib.extend date-utc} \
              --iso
            '';
            test = ''
              ${test-hello}
              ${test-compare}
              ${test-extend}
              ${test-extend-multiline}
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
