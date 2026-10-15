<script setup lang="ts">
// Valve parity: run every finish through our compositor AND Valve's own
// decompiled one (src/valveReference.ts, oracle mode) at a sweep of wear
// values, and rank the finishes by how far the two disagree. The point is the
// wear curve — the strip columns say how much of the atlas each side changes at
// each float — but any compositor difference surfaces here, colour included.
//
// "Ours" is whatever compositePaint renders: the Valve runtime for every
// bundled combo (so a difference there is a wiring bug — inputs, uniforms, the
// epilogue), or, with "hand port" ticked, the port that only renders as a
// fallback now. Comparing the port keeps the fallback honest.
//
// Nothing is written server-side; results persist in this browser so a long
// sweep survives a reload. Gloves are skipped: they run a different shader
// (csgo_customglove) that has no oracle yet.
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { Loader2, Play, Square, Trash2, X } from "lucide-vue-next";
import { fetchTestCatalog, type RenderTestItem } from "../api";
import type { ParityImages, ParityResult } from "../valveParity";

// Results are kept per mode — a runtime sweep and a hand-port sweep answer
// different questions and must not overwrite each other.
const resultsKey = (port: boolean) => `5stack.valveparity.v2.${port ? "port" : "runtime"}`;
const LS_OPTS = "5stack.valveparity.opts.v1";

const catalog = ref<RenderTestItem[]>([]);
const results = ref<Record<number, ParityResult>>({});
const loadError = ref<string | null>(null);

interface Opts {
  wears: string;
  seed: number;
  size: number;
  threshold: number;
  search: string;
  forcePort: boolean;
}
const DEFAULT_OPTS: Opts = { wears: "0.07, 0.15, 0.38, 0.45, 0.7, 1", seed: 1, size: 256, threshold: 0.02, search: "", forcePort: false };
function loadOpts(): Opts {
  try {
    return { ...DEFAULT_OPTS, ...JSON.parse(localStorage.getItem(LS_OPTS) ?? "{}") };
  } catch {
    return { ...DEFAULT_OPTS };
  }
}
const opts = ref<Opts>(loadOpts());
watch(opts, (v) => {
  try { localStorage.setItem(LS_OPTS, JSON.stringify(v)); } catch { /* non-fatal */ }
}, { deep: true });
const wearList = computed(() =>
  opts.value.wears.split(/[,\s]+/).map(Number).filter((w) => Number.isFinite(w) && w >= 0 && w <= 1),
);

function persist() {
  try { localStorage.setItem(resultsKey(opts.value.forcePort), JSON.stringify(results.value)); } catch { /* quota — non-fatal */ }
}
function loadResults() {
  try {
    results.value = JSON.parse(localStorage.getItem(resultsKey(opts.value.forcePort)) ?? "{}");
  } catch {
    results.value = {};
  }
}
watch(() => opts.value.forcePort, loadResults);

onMounted(async () => {
  loadResults();
  try {
    catalog.value = (await fetchTestCatalog()).filter((i) => i.kind !== "glove");
  } catch (e) {
    loadError.value = e instanceof Error ? e.message : String(e);
  }
});

const candidates = computed(() => {
  const q = opts.value.search.trim().toLowerCase();
  return catalog.value.filter((i) => !q || i.name.toLowerCase().includes(q));
});

// ---- the sweep ----------------------------------------------------------------
const running = ref(false);
const done = ref(0);
const total = ref(0);
const current = ref("");
let stop = false;

async function run(items: RenderTestItem[]) {
  if (running.value || !items.length) return;
  const { runParity } = await import("../valveParity");
  running.value = true;
  stop = false;
  done.value = 0;
  total.value = items.length;
  try {
    for (const item of items) {
      if (stop) break;
      current.value = item.name;
      const { result } = await runParity(item, {
        wears: wearList.value,
        seed: opts.value.seed,
        size: opts.value.size,
        forcePort: opts.value.forcePort,
      }).catch((e) => ({ result: { id: item.id, status: "error", wears: [], score: 0, error: String(e) } as ParityResult }));
      results.value = { ...results.value, [item.id]: result };
      done.value++;
      if (done.value % 20 === 0) persist();
    }
  } finally {
    persist();
    running.value = false;
    current.value = "";
  }
}
const runAll = () => run(candidates.value);
const runMissing = () => run(candidates.value.filter((i) => !results.value[i.id]));
const halt = () => (stop = true);
function clearResults() {
  if (running.value) return;
  results.value = {};
  persist();
}
onBeforeUnmount(() => (stop = true));

// For driving a sweep from devtools / automation.
(window as unknown as { __valveParity?: unknown }).__valveParity = {
  results,
  run: (filter?: string) =>
    run(filter ? catalog.value.filter((i) => i.name.toLowerCase().includes(filter.toLowerCase())) : candidates.value),
  runIds: (ids: number[]) => run(catalog.value.filter((i) => ids.includes(i.id))),
  stop: halt,
};

// ---- results ------------------------------------------------------------------
type Row = RenderTestItem & { r: ParityResult };
const rows = computed<Row[]>(() =>
  candidates.value
    .filter((i) => results.value[i.id])
    .map((i) => ({ ...i, r: results.value[i.id] }))
    .sort((a, b) => {
      const rank = (r: ParityResult) => (r.status === "ok" ? 0 : 1);
      if (rank(a.r) !== rank(b.r)) return rank(b.r) - rank(a.r);
      return b.r.score - a.r.score;
    }),
);
const summary = computed(() => {
  const all = Object.values(results.value);
  return {
    checked: all.length,
    flagged: all.filter((r) => r.status === "ok" && r.score > opts.value.threshold).length,
    clean: all.filter((r) => r.status === "ok" && r.score <= opts.value.threshold).length,
    nocombo: all.filter((r) => r.status === "nocombo").length,
    errors: all.filter((r) => r.status === "error").length,
  };
});
const pct = (x: number) => `${(x * 100).toFixed(1)}%`;
const worstWear = (r: ParityResult) => r.wears.reduce((a, b) => (b.visibly > a.visibly ? b : a), r.wears[0]);

// ---- detail ---------------------------------------------------------------------
const detail = ref<Row | null>(null);
const detailWear = ref(0);
const detailImages = ref<ParityImages | null>(null);
const detailBusy = ref(false);
const detailError = ref<string | null>(null);

async function openDetail(row: Row, wear?: number) {
  detail.value = row;
  detailWear.value = wear ?? (row.r.wears.length ? worstWear(row.r).wear : wearList.value[0] ?? 0.5);
  await renderDetail();
}
async function renderDetail() {
  const row = detail.value;
  if (!row) return;
  detailBusy.value = true;
  detailError.value = null;
  detailImages.value = null;
  try {
    const { runParity } = await import("../valveParity");
    const { result, images } = await runParity(row, {
      wears: [detailWear.value],
      seed: opts.value.seed,
      size: 512,
      imagesAt: detailWear.value,
      forcePort: opts.value.forcePort,
    });
    if (result.status !== "ok") detailError.value = result.error ?? result.status;
    detailImages.value = images ?? null;
  } catch (e) {
    detailError.value = e instanceof Error ? e.message : String(e);
  } finally {
    detailBusy.value = false;
  }
}
const closeDetail = () => {
  detail.value = null;
  detailImages.value = null;
};
</script>

<template>
  <section class="rounded-xl border border-border bg-card text-card-foreground shadow">
    <div class="space-y-4 p-6">
      <div class="flex flex-wrap items-start justify-between gap-3">
        <div class="min-w-0 space-y-1">
          <h3 class="text-sm font-semibold uppercase tracking-wider text-foreground">Valve parity</h3>
          <p class="max-w-2xl text-sm text-muted-foreground">
            Runs each finish through our compositor and through Valve's own decompiled shader on the
            same inputs, at every wear below, and ranks finishes by how much of the atlas disagrees.
            Our compositor now runs Valve's shader itself, so a difference is a wiring bug; tick
            <span class="text-foreground">hand port</span> to check the fallback instead.
            <span class="text-foreground">Strip</span> columns compare how much each side wears away.
            Weapons and knives only; results stay in this browser.
          </p>
        </div>
        <div class="flex shrink-0 gap-4 text-sm">
          <div><span class="font-semibold text-foreground">{{ summary.checked }}</span>
            <div class="text-xs text-muted-foreground">checked</div></div>
          <div><span class="font-semibold" :class="summary.flagged ? 'text-red-500' : 'text-foreground'">{{ summary.flagged }}</span>
            <div class="text-xs text-muted-foreground">differ</div></div>
          <div><span class="font-semibold text-emerald-500">{{ summary.clean }}</span>
            <div class="text-xs text-muted-foreground">match</div></div>
          <div v-if="summary.nocombo"><span class="font-semibold text-amber-500">{{ summary.nocombo }}</span>
            <div class="text-xs text-muted-foreground">no combo</div></div>
          <div v-if="summary.errors"><span class="font-semibold text-amber-500">{{ summary.errors }}</span>
            <div class="text-xs text-muted-foreground">errors</div></div>
        </div>
      </div>

      <div class="flex flex-wrap items-center gap-2 text-sm">
        <button v-if="!running"
          :disabled="!candidates.length"
          class="inline-flex h-9 items-center gap-2 rounded-md bg-[hsl(var(--tac-amber))] px-3 text-sm font-medium text-black transition-colors hover:brightness-110 disabled:opacity-40"
          @click="runMissing">
          <Play class="h-3.5 w-3.5" /> Check unchecked ({{ candidates.filter((i) => !results[i.id]).length }})
        </button>
        <button v-else
          class="inline-flex h-9 items-center gap-2 rounded-md border border-border px-3 text-sm font-medium transition-colors hover:bg-muted"
          @click="halt">
          <Square class="h-3.5 w-3.5" /> Stop
        </button>
        <button :disabled="running || !candidates.length"
          class="inline-flex h-9 items-center gap-2 rounded-md border border-border px-3 text-sm transition-colors hover:bg-muted disabled:opacity-40"
          @click="runAll">
          Re-check {{ opts.search ? "matching" : "all" }} ({{ candidates.length }})
        </button>
        <button :disabled="running || !summary.checked"
          class="inline-flex h-9 items-center gap-2 rounded-md border border-border px-3 text-sm text-red-500 transition-colors hover:bg-red-500/10 disabled:opacity-40"
          @click="clearResults">
          <Trash2 class="h-3.5 w-3.5" /> Clear
        </button>
        <input v-model="opts.search" placeholder="Search name…"
          class="h-8 w-48 rounded-md border border-border bg-transparent px-2" />
        <div class="ml-auto flex flex-wrap items-center gap-3 text-muted-foreground">
          <label class="flex items-center gap-1">wears
            <input v-model="opts.wears" :disabled="running"
              class="h-8 w-48 rounded-md border border-border bg-transparent px-2" /></label>
          <label class="flex items-center gap-1">seed
            <input v-model.number="opts.seed" type="number" min="0" max="1000" :disabled="running"
              class="h-8 w-16 rounded-md border border-border bg-transparent px-2" /></label>
          <label class="flex items-center gap-1">size
            <select v-model.number="opts.size" :disabled="running"
              class="h-8 rounded-md border border-border bg-transparent px-1">
              <option :value="128">128</option><option :value="256">256</option><option :value="512">512</option>
            </select></label>
          <label class="flex items-center gap-1" title="Compare the hand port (the fallback) instead of the Valve runtime">
            <input v-model="opts.forcePort" type="checkbox" :disabled="running" /> hand port</label>
          <label class="flex items-center gap-1" title="Share of texels that may differ visibly before a finish counts as differing">flag &gt;
            <input v-model.number="opts.threshold" type="number" min="0" max="1" step="0.01"
              class="h-8 w-16 rounded-md border border-border bg-transparent px-2" /></label>
        </div>
      </div>

      <div v-if="running" class="space-y-1">
        <div class="h-1.5 overflow-hidden rounded-full bg-muted">
          <div class="h-full bg-[hsl(var(--tac-amber))] transition-[width] duration-200"
            :style="{ width: `${total ? (done / total) * 100 : 0}%` }"></div>
        </div>
        <p class="flex items-center gap-2 text-xs text-muted-foreground">
          <Loader2 class="h-3 w-3 animate-spin" /> {{ done }}/{{ total }} — {{ current }}
        </p>
      </div>
      <p v-if="loadError" class="text-sm text-red-500">Failed to load the catalog: {{ loadError }}</p>

      <div v-if="rows.length" class="max-h-[32rem] overflow-auto rounded-md border border-border">
        <table class="w-full text-left text-xs">
          <thead class="sticky top-0 bg-card text-muted-foreground">
            <tr class="border-b border-border">
              <th class="px-2 py-1.5 font-medium">Finish</th>
              <th class="px-2 py-1.5 font-medium">Style · combo</th>
              <th class="px-2 py-1.5 text-right font-medium" title="Worst share of texels that differ visibly">Differs</th>
              <th v-for="w in wearList" :key="w" class="px-2 py-1.5 text-right font-medium tabular-nums"
                :title="`Strip at wear ${w}: ours / Valve`">{{ w }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.id"
              class="cursor-pointer border-b border-border/50 hover:bg-muted/50"
              @click="openDetail(row)">
              <td class="max-w-[16rem] truncate px-2 py-1" :title="row.name">{{ row.name }}
                <span v-if="row.legacy" class="text-muted-foreground"> · legacy</span></td>
              <td class="px-2 py-1 tabular-nums text-muted-foreground">{{ row.r.style ?? "–" }} · {{ row.r.combo ?? "–" }}<span v-if="row.r.path === 'port'" class="text-amber-500"> · port</span></td>
              <td class="px-2 py-1 text-right tabular-nums"
                :class="row.r.status !== 'ok' ? 'text-amber-500' : row.r.score > opts.threshold ? 'text-red-500' : 'text-emerald-500'">
                {{ row.r.status === "ok" ? pct(row.r.score) : row.r.status }}</td>
              <td v-for="w in wearList" :key="w" class="px-2 py-1 text-right tabular-nums"
                @click.stop="openDetail(row, w)">
                <template v-for="pw in row.r.wears.filter((x) => x.wear === w)" :key="pw.wear">
                  <span :class="Math.abs(pw.covOurs - pw.covValve) > opts.threshold ? 'text-red-400' : 'text-muted-foreground'">
                    {{ pct(pw.covOurs) }} / {{ pct(pw.covValve) }}</span>
                </template>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Side by side at one wear: ours, Valve's, and where they disagree. -->
    <div v-if="detail" class="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4" @click.self="closeDetail">
      <div class="flex max-h-full w-full max-w-5xl flex-col overflow-auto rounded-xl border border-border bg-card text-card-foreground shadow-xl">
        <div class="flex items-center gap-2 border-b border-border px-4 py-2.5">
          <div class="min-w-0">
            <p class="truncate text-sm font-medium">{{ detail.name }}</p>
            <p class="text-[11px] text-muted-foreground">style {{ detail.r.style }} · combo {{ detail.r.combo }}<span v-if="detail.legacy"> · legacy</span></p>
          </div>
          <div class="ml-auto flex flex-wrap items-center gap-1">
            <button v-for="w in wearList" :key="w"
              class="h-7 rounded-md border px-2 text-xs tabular-nums"
              :class="w === detailWear ? 'border-[hsl(var(--tac-amber))] bg-[hsl(var(--tac-amber)/0.12)]' : 'border-border hover:bg-muted'"
              :disabled="detailBusy" @click="detailWear = w; renderDetail()">{{ w }}</button>
            <button class="rounded-md p-1.5 text-muted-foreground hover:bg-muted" title="Close" @click="closeDetail">
              <X class="h-4 w-4" />
            </button>
          </div>
        </div>
        <div class="space-y-3 p-4">
          <div v-if="detailBusy" class="flex justify-center py-16"><Loader2 class="h-6 w-6 animate-spin text-[hsl(var(--tac-amber))]" /></div>
          <p v-if="detailError" class="text-sm text-red-500">{{ detailError }}</p>
          <div v-if="detailImages" class="grid grid-cols-1 gap-3 sm:grid-cols-3">
            <figure class="space-y-1"><img :src="detailImages.ours" class="w-full rounded border border-border" />
              <figcaption class="text-xs text-muted-foreground">Ours ({{ opts.forcePort ? "hand port" : "runtime" }}) — albedo atlas</figcaption></figure>
            <figure class="space-y-1"><img :src="detailImages.valve" class="w-full rounded border border-border" />
              <figcaption class="text-xs text-muted-foreground">Valve (decompiled combo {{ detail.r.combo }})</figcaption></figure>
            <figure class="space-y-1"><img :src="detailImages.diff" class="w-full rounded border border-border" />
              <figcaption class="text-xs text-muted-foreground">Difference — red past {{ 24 }} levels</figcaption></figure>
            <figure class="space-y-1"><img :src="detailImages.oursRm" class="w-full rounded border border-border" />
              <figcaption class="text-xs text-muted-foreground">Ours — rough (R) / metal (G)</figcaption></figure>
            <figure class="space-y-1"><img :src="detailImages.valveRm" class="w-full rounded border border-border" />
              <figcaption class="text-xs text-muted-foreground">Valve — rough (R) / metal (G)</figcaption></figure>
          </div>
          <div v-if="detail.r.notes && (detail.r.notes.unbound.length || detail.r.notes.unevaluated.length || detail.r.notes.missingTextures.length)"
            class="space-y-1 rounded-md border border-amber-500/40 bg-amber-500/5 p-2 text-[11px] text-amber-600">
            <p v-if="detail.r.notes.missingTextures.length">No texture for: {{ detail.r.notes.missingTextures.join(", ") }}</p>
            <p v-if="detail.r.notes.unbound.length">Unbound uniforms: {{ detail.r.notes.unbound.join(", ") }}</p>
            <p v-if="detail.r.notes.unevaluated.length">Expressions used raw: {{ detail.r.notes.unevaluated.join("; ") }}</p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
