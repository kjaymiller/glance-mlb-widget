#!/usr/bin/env bash
# Render widget.yml for a specific team by substituting the three template
# tokens and the two URL parameters.
#
# Usage:
#   ./render.sh <teamId> <teamAbbr> <teamName> <teamCode> [season] > out.yml
#
# Example:
#   ./render.sh 144 ATL "Atlanta Braves" atl 2026 > braves.yml
set -euo pipefail

if [[ $# -lt 4 || $# -gt 5 ]]; then
  sed -n '2,12p' "$0" >&2
  exit 1
fi

teamId=$1
teamAbbr=$2
teamName=$3
teamCode=$4
season=${5:-$(date +%Y)}

here=$(cd "$(dirname "$0")" && pwd)

# Strip the template's instructional comment header (everything before the
# first `- type:` line), then write a per-team header.
cat <<EOF
# MLB 7-day team schedule widget for Glance — ${teamName}.
#
# Rendered from https://github.com/kjaymiller/glance-mlb-widget
# (\`render.sh ${teamId} ${teamAbbr} "${teamName}" ${teamCode} ${season}\`).
# Bump season every January.
EOF

sed -e "s/__TEAM_ABBR__/${teamAbbr}/g" \
    -e "s/__TEAM_NAME__/${teamName}/g" \
    -e "s/__TEAM_CODE__/${teamCode}/g" \
    -e "s/teamId: \"\"/teamId: \"${teamId}\"/" \
    -e "s/season: \"2026\"/season: \"${season}\"/" \
    "$here/widget.yml" \
  | sed -n '/^- type:/,$p'
