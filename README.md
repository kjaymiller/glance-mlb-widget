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

The fastest path: grab a **pre-rendered file from `examples/`** matching your team and drop it into your Glance widgets directory.

```bash
curl -O https://raw.githubusercontent.com/kjaymiller/glance-mlb-widget/main/examples/braves.yml
# then $include it from your page in glance.yml
```

If your team isn't in `examples/`, render one with `render.sh`:

```bash
./render.sh <teamId> <teamAbbr> "<teamName>" <teamCode> [season] > my-team.yml
# e.g.
./render.sh 142 MIN "Minnesota Twins" min 2026 > twins.yml
```

Or by hand: copy `widget.yml`, find/replace `__TEAM_ABBR__`, `__TEAM_NAME__`, `__TEAM_CODE__` with your values, then set `teamId` and `season` in the `parameters:` block at the top.

## Why find/replace and not parameters?

Glance's `parameters:` field is a **query-string appender**, not a substitutor. It serializes the keys/values you give it and tacks them onto the request URL — there's no `${var}` interpolation, into either the URL or the template body. So `teamId` and `season` work as real parameters (they ride along on the request as `?teamId=…&season=…`), but `teamAbbr`, `teamName`, and `teamCode` are referenced inside the template body and have to be hardcoded. Hence the find/replace workflow and the `examples/` directory.

## Team IDs

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

`teamCode` is the ESPN CDN code for that team's logo. It's `teamAbbr` lowercased for every team except the Angels (MLB returns `ana` in `fileCode`, but ESPN expects `laa` — the template handles this for opponent logos automatically; you only need to know the quirk when filling in your *own* team's code).

## How it works

- One API call to `/api/v1/schedule?teamId=...&season=...` returns the team's full season (~190 dates, small payload).
- The template projects a 7-day window onto a calendar grid.
- Glance's custom-api template funcset has no iteration helpers (no `until` / `seq` / sprig), so the seven cells of the grid are unrolled by hand. The per-game render is factored into a `define "game"` block.

## Caveats

- **Bump `season` every January.** MLB StatsAPI doesn't expose a "current season" alias, and Glance can't compute parameter values via Go templates.
- **Refresh cadence**: 5 minutes (`cache: 5m`). Live scores will lag behind broadcast by up to that long.
- Logos are fetched from ESPN's CDN. If their URL scheme changes, the widget will show broken images until the template is updated.

## License

MIT
