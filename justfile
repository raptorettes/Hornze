# Launch Godot editor
dev:
    nohup godot ./godot/project.godot &> /dev/null & disown

# Run opening scene
play:
    godot run --path . --scene ./godot/scenes/arachnoise.tscn

# Serve the preview files
serve:
    bunx vite ./exports/web/

# Export
export:
    godot --export-release Web ./exports/web/index.html

build-manifest:
  ./build-manifest.sh

# Run pipeline locally with woodpecker-cli
ci-local:
    #!/usr/bin/env fish
    set -l TMP (mktemp -d)

    if not set -q PROJECT; or not set -q GODOT_VERSION
        echo "PROJECT and GODOT_VERSION must be set"
        exit 1
    end

    # Decrypt secrets
    sops -d secrets/woodpecker.yaml > $TMP/secrets.yaml

    envsubst '${PROJECT} ${GODOT_VERSION}' < .woodpecker.yml > $TMP/pipeline.yml

    # Ensure podman socket is available (rootless)
    #  if not test -S /run/user/(id -u)/podman/podman.sock
    #      echo "Starting podman socket..."
    #      systemctl --user start podman.socket
    #      sleep 1
    #  end

    set -gx DOCKER_HOST unix:///run/user/(id -u)/podman/podman.sock

    # Run pipeline locally
    woodpecker-cli exec \
        --backend-engine docker \
        --secrets-file $TMP/secrets.yaml \
        $TMP/pipeline.yml

    rm -rf $TMP
