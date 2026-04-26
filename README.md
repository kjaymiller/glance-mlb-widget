# glance-mlb-widget

A 7-day schedule widget for any MLB team, for [Glance](https://github.com/glanceapp/glance).

Shows a calendar grid centered on today (3 days back, 3 days forward) with:

- **Final** games as `W` / `L` plus score, with a YouTube highlights link
- **Live** games as `LIVE` with current inning and score
- **Scheduled** games as the local-time first pitch
- Opponent logo in each cell, `@` / `vs` indicator
- Each game links to the MLB Gameday page

Built on the public [MLB StatsAPI](https://statsapi.mlb.com/) and [ESPN's logo CDN](https://a.espncdn.com/). No auth, no API key.

## Install

Drop `widget.yml` into your Glance config — either reference it via `$include` or paste it inline. Fill in the five parameters for your team:

```yaml
# in your page's widgets list:
- !include /path/to/widget.yml
  parameters:
    teamId: "144"
    teamAbbr: "ATL"
    teamName: "Atlanta Braves"
    teamCode: "atl"
    season: "2026"
```

Or paste the widget body directly into your page and edit the `parameters:` block at the top.

See `examples/` for ready-to-use snippets for a few teams.

## Parameters

| Name | What it is | Example |
| --- | --- | --- |
| `teamId` | MLB StatsAPI numeric team ID | `144` (Braves) |
| `teamAbbr` | 3-letter abbreviation as MLB StatsAPI returns it | `ATL` |
| `teamName` | Display name shown next to the logo and used in the YouTube highlights search | `Atlanta Braves` |
| `teamCode` | ESPN CDN logo code (lowercase). Usually `teamAbbr` lowercased; **Angels = `laa`** | `atl` |
| `season` | 4-digit year. Bump every January. | `2026` |

### Team IDs

| Team | `teamId` | `teamAbbr` | `teamCode` |
| --- | --- | --- | --- |
| Arizona Diamondbacks | 109 | ARI | ari |
| Atlanta Braves | 144 | ATL | atl |
| Baltimore Orioles | 110 | BAL | bal |
| Boston Red Sox | 111 | BOS | bos |
| Chicago Cubs | 112 | CHC | chc |
| Chicago White Sox | 145 | CWS | chw |
| Cincinnati Reds | 113 | CIN | cin |
| Cleveland Guardians | 114 | CLE | cle |
| Colorado Rockies | 115 | COL | col |
| Detroit Tigers | 116 | DET | det |
| Houston Astros | 117 | HOU | hou |
| Kansas City Royals | 118 | KC | kc |
| Los Angeles Angels | 108 | LAA | laa |
| Los Angeles Dodgers | 119 | LAD | lad |
| Miami Marlins | 146 | MIA | mia |
| Milwaukee Brewers | 158 | MIL | mil |
| Minnesota Twins | 142 | MIN | min |
| New York Mets | 121 | NYM | nym |
| New York Yankees | 147 | NYY | nyy |
| Oakland Athletics | 133 | OAK | oak |
| Philadelphia Phillies | 143 | PHI | phi |
| Pittsburgh Pirates | 134 | PIT | pit |
| San Diego Padres | 135 | SD | sd |
| San Francisco Giants | 137 | SF | sf |
| Seattle Mariners | 136 | SEA | sea |
| St. Louis Cardinals | 138 | STL | stl |
| Tampa Bay Rays | 139 | TB | tb |
| Texas Rangers | 140 | TEX | tex |
| Toronto Blue Jays | 141 | TOR | tor |
| Washington Nationals | 120 | WSH | wsh |

## How it works

- One API call to `/api/v1/schedule?teamId=...&season=...` returns the team's full season (~190 dates, small payload).
- The template projects a 7-day window onto a calendar grid.
- Glance applies `${var}` substitution to both the `url` and `template` fields before the Go-template engine runs — that's how parameters reach the template body.
- Glance's custom-api template funcset has no iteration helpers (no `until` / `seq` / sprig), so the seven cells of the grid are unrolled by hand. The per-game render is factored into a `define "game"` block.
- The Angels are `ana` in MLB's `fileCode` field but `laa` on ESPN's CDN, so the template rewrites that one case for opponent logos.

## Caveats

- **Bump `season` every January.** MLB StatsAPI doesn't expose a "current season" alias, and Glance can't compute parameter values via Go templates.
- **Refresh cadence**: 5 minutes (`cache: 5m`). Live scores will lag behind broadcast by up to that long.
- Logos are fetched from ESPN's CDN. If their URL scheme changes, the widget will show broken images until the template is updated.

## License

MIT
