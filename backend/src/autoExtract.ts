// Self-heal on boot. A mount that is empty or behind the pipeline means blank
// item art and white skins — there is nothing an admin would do about it except
// press the button, so press it for them. Set INVENTORY_AUTO_EXTRACT=0 to
// disable (e.g. a node where the ~30 minute run is unwelcome at startup).
//
// A node whose CS2 install isn't readable yet (a fresh install whose game server
// is still downloading it) is looked at again on every `later` until it is.
// Checking once at boot left those mounts on "Never run" for good.
//
// Apart from main.ts so tools/auto-extract-check.ts can drive it with fakes.

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

export function autoExtractor(deps: AutoExtractDeps): () => Promise<void> {
  // The blocker is cheap to ask; the version info reads steam.inf and warns when
  // it can't, which every retry against a missing install would repeat.
  // Runs from a timer, where a rejection is unhandled and takes the process down.
  const retry = async () => {
    try {
      if (await deps.blocker()) {
        deps.later(retry);
        return;
      }
    } catch (e) {
      deps.log.warn(`[extract-models] auto-run check failed: ${(e as Error).message}`);
      return;
    }
    await autoExtractIfStale();
  };
  async function autoExtractIfStale() {
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
      if (blocked) deps.later(retry);
    } catch (e) {
      deps.log.warn(`[extract-models] auto-run check failed: ${(e as Error).message}`);
    }
  }
  return autoExtractIfStale;
}
