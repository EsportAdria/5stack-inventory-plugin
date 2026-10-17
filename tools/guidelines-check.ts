// Does the Game Server tab only ask for Valve's server guidelines to be turned
// off when they are still on?
//
// Run: node --experimental-strip-types tools/guidelines-check.ts
//
// 5stack Ranks turns the same setting off, and the panel's plugin page then
// shows "already off" with no switch. The tab still showed its amber banner and
// sent the operator to that page, where there was nothing to press.
import { guidelinesAlreadyOff } from "../backend/src/panel.ts";

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

if (failures) {
  console.error(`\n${failures} failure(s)`);
  process.exit(1);
}
console.log("\nall guidelines checks pass");
