// Does a stale mount still extract itself when the CS2 install shows up late?
//
// Run: node --experimental-strip-types tools/auto-extract-check.ts
//
// The auto-run used to look exactly once, at boot. On a fresh install the
// game-server node is often still downloading CS2 then, so the run refused
// ("CS2 install not readable"), logged a warning nobody reads, and the panel sat
// on "Never run" with item art hidden until an admin happened to press the
// button. Nothing crashes in that failure, so it is pinned here.
import { autoExtractor, type AutoExtractDeps } from "../backend/src/autoExtract.ts";

let failures = 0;
function check(label: string, got: unknown, want: unknown) {
  const g = JSON.stringify(got);
  const w = JSON.stringify(want);
  if (g !== w) {
    console.error(`FAIL ${label}\n  got  ${g}\n  want ${w}`);
    failures++;
  } else {
    console.log(`ok   ${label}  ${g}`);
  }
}

const MISSING = "CS2 install not readable at /cs2-game (looked for game/csgo/pak01_dir.vpk).";

function harness(overrides: Partial<AutoExtractDeps> = {}) {
  const world = { installed: false, stale: true, failed: false, enabled: true, starts: 0, timers: [] as (() => void)[], warnings: [] as string[] };
  const deps: AutoExtractDeps = {
    enabled: () => world.enabled,
    versionInfo: async () => ({ stale: world.stale, extractVersion: null, requiredVersion: 40 }),
    running: async () => null,
    lastRunFailed: async () => world.failed,
    blocker: async () => (world.installed ? null : MISSING),
    start: async () => {
      if (!world.installed) return { code: 412, error: MISSING };
      world.starts++;
      world.stale = false;
      return { started: true };
    },
    later: (fn) => void world.timers.push(fn),
    log: { info: () => {}, warn: (m) => void world.warnings.push(m) },
    ...overrides,
  };
  const run = autoExtractor(deps);
  // Fire every pending retry, as many rounds as asked.
  const tick = async (rounds = 1) => {
    for (let i = 0; i < rounds; i++) {
      const due = world.timers.splice(0);
      for (const fn of due) await fn();
    }
  };
  return { world, run, tick };
}

{
  const { world, run, tick } = harness();
  await run();
  check("install missing at boot: nothing started", world.starts, 0);
  check("install missing at boot: a retry is scheduled", world.timers.length, 1);
  await tick(3);
  check("still missing: no start, still waiting", [world.starts, world.timers.length], [0, 1]);
  check("still missing: warned once, not every retry", world.warnings.length, 1);
  world.installed = true;
  await tick();
  check("install appears: the extraction starts", world.starts, 1);
  check("after it starts: no more retries", world.timers.length, 0);
}

{
  const { world, run } = harness();
  world.installed = true;
  await run();
  check("installed at boot: starts straight away", [world.starts, world.timers.length], [1, 0]);
}

{
  const { world, run } = harness();
  world.stale = false;
  await run();
  check("mount up to date: nothing to wait for", [world.starts, world.timers.length], [0, 0]);
}

{
  const { world, run } = harness();
  world.failed = true;
  await run();
  check("last run failed: left for a human", [world.starts, world.timers.length], [0, 0]);
}

{
  const { world, run } = harness();
  world.enabled = false;
  await run();
  check("INVENTORY_AUTO_EXTRACT=0: never waits either", [world.starts, world.timers.length], [0, 0]);
}

{
  const { world, run, tick } = harness();
  await run();
  world.installed = true;
  world.failed = true;
  await tick();
  check("a manual run that failed while waiting stops the retries", [world.starts, world.timers.length], [0, 0]);
}

{
  const { world, run } = harness({ start: async () => ({ code: 409, error: "Extraction is already running." }) });
  world.installed = true;
  await run();
  check("refused for another reason: no retry loop", world.timers.length, 0);
}

if (failures) {
  console.error(`\n${failures} failure(s)`);
  process.exit(1);
}
console.log("\nall auto-extract checks pass");
