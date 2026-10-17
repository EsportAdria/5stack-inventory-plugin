// Does the Game Server tab only ask for Valve's server guidelines to be turned
// off when they are still on?
//
// Run: node --experimental-strip-types tools/guidelines-check.ts
//
// 5stack Ranks turns the same setting off, and the panel's plugin page then
// shows "already off" with no switch. The tab still showed its amber banner and
// sent the operator to that page, where there was nothing to press.
import { gamePluginState, guidelinesAlreadyOff } from "../backend/src/panel.ts";

let failures = 0;
function check(label: string, got: unknown, want: unknown) {
  if (JSON.stringify(got) !== JSON.stringify(want)) {
    console.error(`FAIL ${label}\n  got  ${JSON.stringify(got)}\n  want ${JSON.stringify(want)}`);
    failures++;
  } else {
    console.log(`ok   ${label}  ${JSON.stringify(got)}`);
  }
}

const ranks = (name: string, value: string | null) => [{ name, value }];

check("the plugin's own opt-in", guidelinesAlreadyOff(true, []), true);
check("ranks on matches", guidelinesAlreadyOff(false, ranks("fivestack_ranks_matches", "true")), true);
check("ranks on tournaments", guidelinesAlreadyOff(false, ranks("fivestack_ranks_tournaments", "true")), true);
check("ranks turned off", guidelinesAlreadyOff(false, ranks("fivestack_ranks_matches", "false")), false);
check("ranks never set", guidelinesAlreadyOff(false, ranks("fivestack_ranks_matches", null)), false);
check("an unrelated setting", guidelinesAlreadyOff(false, ranks("public.something_else", "true")), false);
check("nothing turned them off", guidelinesAlreadyOff(false, []), false);

// Through gamePluginState too: the settings read swallows every error, so a
// broken query or a lost await would quietly bring the banner back.
const queries: Array<string> = [];
function panel(ranks: string | null, ranksRefused = false) {
  queries.length = 0;
  globalThis.fetch = (async (_url: unknown, init?: { body?: unknown }) => {
    const { query } = JSON.parse(String(init?.body)) as { query: string };
    queries.push(query);
    if (query.includes("rankSettings")) {
      if (ranksRefused) {
        return new Response(JSON.stringify({ errors: [{ message: "field 'settings' not found" }] }));
      }
      const settings = ranks === null ? [] : [{ name: "fivestack_ranks_matches", value: ranks }];
      return new Response(JSON.stringify({ data: { settings } }));
    }
    return new Response(
      JSON.stringify({
        data: {
          game_plugins: [
            { slug: "inventory-simulator", install_state: null, requires_server_guidelines_disabled: true, versions: [] },
          ],
          game_plugin_installs: [{ plugin_slug: "inventory-simulator", disable_server_guidelines: false }],
        },
      }),
    );
  }) as typeof fetch;
}

panel("true");
check("ranks on reaches the Game Server tab", (await gamePluginState("cookie")).guidelinesDisabled, true);
check(
  "the read names both ranks settings",
  queries.some((query) => query.includes("fivestack_ranks_matches") && query.includes("fivestack_ranks_tournaments")),
  true,
);
panel(null);
check("ranks never set leaves the banner", (await gamePluginState("cookie")).guidelinesDisabled, false);
panel("true", true);
check("a refused settings read still loads the tab", (await gamePluginState("cookie")).installed, true);

if (failures) {
  console.error(`\n${failures} failure(s)`);
  process.exit(1);
}
console.log("\nall guidelines checks pass");
