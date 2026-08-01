#!/usr/bin/env bash
# Install xAI Grok CLI as user sachs.
set -euo pipefail
runuser -u sachs -- bash -c 'curl -fsSL https://x.ai/cli/install.sh | bash'
