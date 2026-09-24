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

# Install agent skills pinned in skills-lock.json (source: studyu-health/studyu-agent-marketplace).
if command -v npx >/dev/null 2>&1; then
  echo "Installing agent skills via npx skills..."
  if ! DISABLE_TELEMETRY=1 npx --yes skills@1.7.0 experimental_install; then
    echo "Warning: agent skills could not be installed. Check marketplace access and re-run ./setup.sh." >&2
  elif [ ! -d .agents/skills ]; then
    echo "Warning: marketplace installer returned without skills; check skills-lock.json and re-run ./setup.sh." >&2
  fi
  # Remove legacy per-skill links so Claude reads only the canonical directory.
  if [ -d .claude/skills ] && [ ! -L .claude/skills ]; then
    find .claude/skills -mindepth 1 -maxdepth 1 -type l -delete
    rmdir .claude/skills 2>/dev/null || echo "Warning: .claude/skills contains files; move them and re-run ./setup.sh." >&2
  fi
  if [ ! -L .claude/skills ] && [ -e .agents/skills ]; then
    ln -s ../.agents/skills .claude/skills
  fi
else
  echo "Warning: npx not found; agent skills not installed. Install Node >= 22.20 and re-run ./setup.sh." >&2
fi

echo "Setup complete!"
