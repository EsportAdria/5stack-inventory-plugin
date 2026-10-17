// Does a stale mount still extract itself when the CS2 install shows up late?
//
// Run: node --experimental-strip-types tools/auto-extract-check.ts
//
// The auto-run used to look exactly once, at boot. On a fresh install the
// game-server node is often still downloading CS2 then, so the run refused
// ("CS2 install not readable"), logged a warning nobody reads, and the panel sat
// on "Never run" with item art hidden until an admin happened to press the
// button. Nothing crashes in that failure, so it is pinned here.
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import os from "node:os";
import path from "node:path";
import { autoExtractor, installProblem, type AutoExtractDeps } from "../backend/src/autoExtract.ts";

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
  const { run, waiting } = autoExtractor(deps);
  // Fire every pending retry, as many rounds as asked.
  const tick = async (rounds = 1) => {
    for (let i = 0; i < rounds; i++) {
      const due = world.timers.splice(0);
      for (const fn of due) await fn();
    }
  };
  return { world, run, waiting, tick };
}

{
  const { world, run, waiting, tick } = harness();
  await run();
  check("install missing at boot: nothing started", world.starts, 0);
  check("install missing at boot: a retry is scheduled", [world.timers.length, waiting()], [1, true]);
  await tick(3);
  check("still missing: no start, still waiting", [world.starts, world.timers.length, waiting()], [0, 1, true]);
  check("still missing: warned once, not every retry", world.warnings.length, 1);
  world.installed = true;
  await tick();
  check("install appears: the extraction starts", world.starts, 1);
  check("after it starts: no more retries, not waiting", [world.timers.length, waiting()], [0, false]);
}

{
  let boom = false;
  const { world, run, waiting, tick } = harness({
    versionInfo: async () => {
      if (boom) throw new Error("database went away");
      return { stale: world.stale, extractVersion: null, requiredVersion: 40 };
    },
  });
  await run();
  world.installed = true;
  boom = true;
  await tick();
  check("a throw while waiting keeps waiting", [world.starts, world.timers.length, waiting()], [0, 1, true]);
  boom = false;
  await tick();
  check("and the next look starts it", world.starts, 1);
}

{
  const { world, run, waiting } = harness({ running: async () => 4242 });
  world.installed = true;
  await run();
  check("a run already going: no second one, no retry", [world.starts, world.timers.length, waiting()], [0, 0, false]);
}

{
  const { world, run, waiting } = harness({ versionInfo: async () => { throw new Error("db down at boot"); } });
  await run();
  check("a throw at boot is not a wait", [world.timers.length, waiting()], [0, false]);
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

// The install itself. Starting on a half-downloaded one fails the run, and a
// failed run is never retried, so "has the vpk" is not enough.
const scratch = mkdtempSync(path.join(os.tmpdir(), "auto-extract-check-"));
function cs2Dir(files: Record<string, string>) {
  const dir = mkdtempSync(path.join(scratch, "cs2-"));
  for (const [rel, body] of Object.entries(files)) {
    mkdirSync(path.dirname(path.join(dir, rel)), { recursive: true });
    writeFileSync(path.join(dir, rel), body);
  }
  return dir;
}
const GAME = { "game/csgo/pak01_dir.vpk": "", "game/csgo/steam.inf": "ClientVersion=1\n" };
const ready = async (files: Record<string, string>) => (await installProblem(cs2Dir(files))) === null;
check("empty dir is not ready", await ready({}), false);
check("vpk without steam.inf is not ready", await ready({ "game/csgo/pak01_dir.vpk": "" }), false);
check("a dir the operator pointed at (no manifest, no build file) is ready", await ready(GAME), true);
check(
  "steamcmd done (StateFlags 4) is ready",
  await ready({ ...GAME, "steamapps/appmanifest_730.acf": '"AppState"\n{\n\t"StateFlags"\t\t"4"\n}\n' }),
  true,
);
check(
  "installed with a newer build out (StateFlags 6) is ready",
  await ready({ ...GAME, "steamapps/appmanifest_730.acf": '"AppState"\n{\n\t"StateFlags"\t\t"6"\n}\n' }),
  true,
);
check(
  "updating over an installed build (StateFlags 1030) is not",
  await ready({ ...GAME, "steamapps/appmanifest_730.acf": '"AppState"\n{\n\t"StateFlags"\t\t"1030"\n}\n' }),
  false,
);
check(
  "steamcmd mid-download (StateFlags 1026) is not",
  await ready({ ...GAME, "steamapps/appmanifest_730.acf": '"AppState"\n{\n\t"StateFlags"\t\t"1026"\n}\n' }),
  false,
);
check("pinned update running (build file, no manifest yet) is not", await ready({ ...GAME, ".5stack.build": "123" }), false);
check(
  "pinned update done (its manifest has no StateFlags) is ready",
  await ready({ ...GAME, ".5stack.build": "123", "steamapps/appmanifest_730.acf": '"AppState"\n{\n\t"buildid"\t\t"123"\n}\n' }),
  true,
);

rmSync(scratch, { recursive: true, force: true });

if (failures) {
  console.error(`\n${failures} failure(s)`);
  process.exit(1);
}
console.log("\nall auto-extract checks pass");
