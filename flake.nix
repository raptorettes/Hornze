{
  description = "Nix based Godot dev template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let

      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ] (system: function nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          project = "Hornse";
          godotVersion = "4.7.1";
          godot = pkgs.godotPackages_4_7.godot;

        in
        {
          default = pkgs.mkShell {

            buildInputs = with pkgs; [
              godot
              bun
              just
              python3
              python3Packages.pyyaml
              rclone
              git
              sops
              age
              yq
              jq
              woodpecker-cli
            ];

            shellHook = ''
              export PROJECT=${project}
              export GODOT_VERSION=${godotVersion}

              echo ""
              echo " * /-----"
              echo " * | Godot development environment"
              echo " * | Project: $PROJECT"
              echo " * | Godot version: $GODOT_VERSION ($(godot --version))"
              echo " * \-----"
              echo " * "
              echo " *  Start the project menu with: just, up, or dev"
              echo " *"
              echo ""
              just -l
              echo ""
            '';
          };
        }
      );
    };
}
