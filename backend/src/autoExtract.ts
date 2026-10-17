// Self-heal on boot. A mount that is empty or behind the pipeline means blank
// item art and white skins — there is nothing an admin would do about it except
// press the button, so press it for them. Set INVENTORY_AUTO_EXTRACT=0 to
// disable (e.g. a node where the ~30 minute run is unwelcome at startup).
//
// A node whose CS2 install isn't ready yet (a fresh install whose game server
// is still downloading it) is looked at again on every `later` until it is.
// Checking once at boot left those mounts on "Never run" for good.
//
// Apart from main.ts so tools/auto-extract-check.ts can drive it with fakes.
import { promises as fs } from "node:fs";
import path from "node:path";

type StartResult = { started: true } | { code: number; error: string };

export interface AutoExtractDeps {
  enabled: () => boolean;
  versionInfo: () => Promise<{ stale: boolean; extractVersion: number | null; requiredVersion: number | null }>;
  running: () => Promise<number | null>;
  lastRunFailed: () => Promise<boolean>;
  /** Why a run can't start on this node yet, or null. */
  blocker: () => Promise<string | null>;
  start: () => Promise<StartResult>;
  later: (fn: () => void) => void;
  log: { info: (msg: string) => void; warn: (msg: string) => void };
}

/** Why an extraction can't start against `dir` right now, or null. Fresh
 *  installs hit this while the game server is still downloading CS2, so the
 *  auto-run waits on it and the panel shows it. */
export async function installProblem(dir: string): Promise<string | null> {
  const exists = (rel: string) => fs.access(path.join(dir, rel)).then(() => true, () => false);
  if (!(await exists("game/csgo/pak01_dir.vpk")) || !(await exists("game/csgo/steam.inf"))) {
    return `No CS2 install at ${dir} (looked for game/csgo/pak01_dir.vpk and steam.inf). The inventory has to run on a node that hosts game servers, or set CS2_DIR.`;
  }
  // A run started on a half-downloaded install fails, and a failed run switches
  // the auto-run off for good. A game node's update deletes steamapps/ first: a
  // pinned build writes the manifest last (with .5stack.build there throughout),
  // and steamcmd's StateFlags is a bitmask that only reads 4 (fully installed),
  // plus 2 when a newer build is out, once nothing is downloading. No manifest
  // and no build file is a CS2 dir the operator pointed us at.
  const manifest = await fs.readFile(path.join(dir, "steamapps", "appmanifest_730.acf"), "utf8").catch(() => null);
  const flagsText = manifest?.match(/"StateFlags"\s+"(\d+)"/)?.[1];
  const flags = flagsText === undefined ? null : Number(flagsText);
  const pinnedUpdateRunning = manifest === null && (await exists(".5stack.build"));
  const steamcmdBusy = flags !== null && ((flags & 4) === 0 || (flags & ~6) !== 0);
  if (pinnedUpdateRunning || steamcmdBusy) {
    return `CS2 at ${dir} is still downloading or updating.`;
  }
  return null;
}

export interface AutoExtractor {
  run: () => Promise<void>;
  /** A retry is scheduled: the run starts by itself once the install is ready. */
  waiting: () => boolean;
}

export function autoExtractor(deps: AutoExtractDeps): AutoExtractor {
  let waiting = false;
  const wait = () => {
    waiting = true;
    deps.later(retry);
  };
  // Runs from a timer, where a rejection is unhandled and takes the process down.
  // The blocker is cheap to ask; the version info reads steam.inf and warns when
  // it can't, which every retry against a missing install would repeat.
  async function retry() {
    try {
      if (await deps.blocker()) {
        deps.later(retry);
        return;
      }
    } catch (e) {
      deps.log.warn(`[extract-models] auto-run check failed: ${(e as Error).message}`);
      deps.later(retry);
      return;
    }
    await run();
  }
  async function run() {
    const wasWaiting = waiting;
    waiting = false;
    if (!deps.enabled()) return;
    try {
      const info = await deps.versionInfo();
      if (!info.stale) return;
      // Already running, started by a process that has since been replaced —
      // `node --watch` restarts on every edit, and without this the auto-run
      // stacks a second extraction on top of the live one.
      const running = await deps.running();
      if (running !== null) {
        deps.log.info(`[extract-models] already running (pid ${running}) — not auto-starting another`);
        return;
      }
      // A previous run that FAILED is not something to retry on every restart —
      // a crash-looping pod would spawn a multi-GB job each time, and the failure
      // wants a human. Manual re-run still works.
      if (await deps.lastRunFailed()) {
        deps.log.warn("[extract-models] mount is stale but the last run failed — not auto-running; re-run it from the panel");
        return;
      }
      deps.log.info(
        `[extract-models] mount is stale (has v${info.extractVersion ?? "none"}, script produces v${info.requiredVersion}) — starting automatically`,
      );
      const result = await deps.start();
      if (!("code" in result)) return;
      const blocked = await deps.blocker();
      deps.log.warn(`[extract-models] auto-run could not start: ${result.error}${blocked ? " — will start once it can" : ""}`);
      if (blocked) wait();
    } catch (e) {
      deps.log.warn(`[extract-models] auto-run check failed: ${(e as Error).message}`);
      // A blip (the database, say) mid-wait must not end the wait for good.
      if (wasWaiting) wait();
    }
  }
  return { run, waiting: () => waiting };
}
