#!/bin/bash
set -e

# Use the FVM-pinned Dart SDK so the setup honors .fvmrc.
if ! command -v fvm >/dev/null 2>&1; then
  echo "fvm not found on PATH. Install FVM and run './setup.sh' again." >&2
  exit 1
fi

# Install the Flutter SDK pinned in .fvmrc.
echo "Installing the Flutter SDK via fvm..."
fvm install

# Create the local environment file without overwriting developer changes.
env_example="flutter_common/lib/envs/.env.local.example"
env_local="flutter_common/lib/envs/.env.local"
[ -e "$env_local" ] || cp "$env_example" "$env_local"

# Resolve root dependencies via the pinned SDK. This also resolves the
# workspace-local Melos package from the lockfile.
echo "Running fvm dart pub get in root project..."
fvm dart pub get

# Bootstrap Melos packages via the lockfile-resolved package.
echo "Bootstrapping Melos packages via fvm dart run melos..."
fvm dart run melos bootstrap

# Install agent skills and MCP config from studyu-health/studyu-agent-marketplace.
marketplace_ref="${STUDYU_AGENT_MARKETPLACE_REF:-main}"
marketplace_dir="${XDG_CACHE_HOME:-$HOME/.cache}/studyu-agent-marketplace"
rm -rf "$marketplace_dir"
if git clone --quiet --depth 1 --branch "$marketplace_ref" https://github.com/studyu-health/studyu-agent-marketplace.git "$marketplace_dir"; then
  bash "$marketplace_dir/bin/install.sh" all "$PWD" || echo "Warning: agent setup failed; re-run ./setup.sh." >&2
else
  echo "Warning: could not fetch the agent marketplace; agent skills and MCP servers not installed. Re-run ./setup.sh." >&2
fi

echo "Setup complete!"
