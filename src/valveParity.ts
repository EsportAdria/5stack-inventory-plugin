// Parity check: our compositor vs Valve's own (valveReference.ts), per finish,
// across a sweep of wear values. The answer to "is every skin's wear right?"
// without a human paging through 2000 finishes at six floats each.
//
// Both sides render the same finish, seed and inputs into same-sized atlases;
// we read back all four outputs and report:
//  - visibly: share of texels whose albedo differs by more than VISIBLE (max
//    channel, sRGB bytes) — the ranking key, because a mean hides a localised
//    wrong region and a localised wrong region is exactly what a bad wear curve
//    looks like;
//  - dAlbedo: mean absolute albedo difference;
//  - covOurs / covValve: share of texels the wear CHANGED relative to the same
//    implementation at wear 0 — "Valve strips 31% at this float, we strip 6%".
//    That pair is the direct wear-curve comparison, independent of colour.
//  - dRough / dMetal: mean absolute difference of the rough/metal outputs.
//
// It measures the UV ATLAS, not the playside: gutters and the back of the gun
// count the same as the slide. Fine for parity (both sides share the atlas),
// wrong for "how much does it show" — don't quote these as visible coverage.
import {
  compositePaint,
  evictPaintTextures,
  loadPaintDef,
  loadWeaponInputs,
  type CompositeReferenceCtx,
} from "./paintComposite";
import { loadValveCombo, renderValveReference, valveComboId, type ValveRefNotes } from "./valveReference";
import { viewer3d } from "./viewer3dLazy";

/** A texel is "visibly" different past this many sRGB levels in any channel. */
export const VISIBLE = 24;

export interface ParityItem {
  id: number;
  name: string;
  model: string;
  paintMaterial: string;
  legacy: boolean;
}

export interface ParityWear {
  wear: number;
  visibly: number;
  dAlbedo: number;
  covOurs: number;
  covValve: number;
  dRough: number;
  dMetal: number;
}

export interface ParityResult {
  id: number;
  status: "ok" | "nocombo" | "error";
  combo?: number;
  style?: number;
  /** Which compositor "ours" was: the Valve runtime, or the hand port (forced,
   *  or fallen back to because the combo would not run). */
  path?: "valve" | "port";
  wears: ParityWear[];
  /** Worst `visibly` over the sweep. */
  score: number;
  notes?: ValveRefNotes;
  error?: string;
}

export interface ParityImages {
  wear: number;
  ours: string;
  valve: string;
  diff: string;
  oursRm: string;
  valveRm: string;
}

interface Frame {
  albedo: Uint8Array;
  rm: Uint8Array;
}

// A macrotask yield that background tabs do not throttle. setTimeout is clamped
// to ~1s in a hidden tab, which turns a two-hour sweep into a ten-hour one for
// no reason; MessageChannel delivery is not throttled.
const yieldTask = () =>
  new Promise<void>((resolve) => {
    const ch = new MessageChannel();
    ch.port1.onmessage = () => resolve();
    ch.port2.postMessage(0);
  });

async function readRT(ctx: CompositeReferenceCtx, rt: import("three").WebGLRenderTarget): Promise<Uint8Array> {
  const buf = new Uint8Array(ctx.size * ctx.size * 4);
  ctx.renderer.readRenderTargetPixels(rt, 0, 0, ctx.size, ctx.size, buf);
  return buf;
}

function toDataUrl(px: Uint8Array, size: number, map?: (px: Uint8Array, i: number, out: Uint8ClampedArray) => void): string {
  const c = document.createElement("canvas");
  c.width = c.height = size;
  const g = c.getContext("2d")!;
  const img = g.createImageData(size, size);
  // Render targets read back bottom-up; flip so the atlas reads like the PNGs.
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const i = ((size - 1 - y) * size + x) * 4;
      const o = (y * size + x) * 4;
      if (map) map(px, i, img.data.subarray(o, o + 4) as unknown as Uint8ClampedArray);
      else {
        img.data[o] = px[i];
        img.data[o + 1] = px[i + 1];
        img.data[o + 2] = px[i + 2];
        img.data[o + 3] = 255;
      }
    }
  }
  g.putImageData(img, 0, 0);
  return c.toDataURL("image/png");
}

function compare(o: Frame, v: Frame, o0: Frame, v0: Frame, wear: number): ParityWear {
  let vis = 0, dA = 0, cO = 0, cV = 0, dR = 0, dM = 0;
  const n = o.albedo.length / 4;
  for (let i = 0; i < o.albedo.length; i += 4) {
    const dr = Math.abs(o.albedo[i] - v.albedo[i]);
    const dg = Math.abs(o.albedo[i + 1] - v.albedo[i + 1]);
    const db = Math.abs(o.albedo[i + 2] - v.albedo[i + 2]);
    dA += (dr + dg + db) / 3;
    if (Math.max(dr, dg, db) > VISIBLE) vis++;
    const co = Math.max(Math.abs(o.albedo[i] - o0.albedo[i]), Math.abs(o.albedo[i + 1] - o0.albedo[i + 1]), Math.abs(o.albedo[i + 2] - o0.albedo[i + 2]));
    const cv = Math.max(Math.abs(v.albedo[i] - v0.albedo[i]), Math.abs(v.albedo[i + 1] - v0.albedo[i + 1]), Math.abs(v.albedo[i + 2] - v0.albedo[i + 2]));
    if (co > VISIBLE) cO++;
    if (cv > VISIBLE) cV++;
    // Ours packs (sfx, rough, metal); Valve's is (rough, metal, sfx, pearl).
    dR += Math.abs(o.rm[i + 1] - v.rm[i]);
    dM += Math.abs(o.rm[i + 2] - v.rm[i + 1]);
  }
  const r = (x: number) => +x.toFixed(4);
  return {
    wear,
    visibly: r(vis / n),
    dAlbedo: +(dA / n).toFixed(2),
    covOurs: r(cO / n),
    covValve: r(cV / n),
    dRough: +(dR / n).toFixed(2),
    dMetal: +(dM / n).toFixed(2),
  };
}

/**
 * Run one finish through both compositors at every wear in `wears` (wear 0 is
 * always added — coverage is measured against it). With `imagesAt`, also
 * returns ours / Valve's / a difference heatmap at that wear.
 */
export async function runParity(
  item: ParityItem,
  opts: { wears: number[]; seed: number; size: number; imagesAt?: number; forcePort?: boolean },
): Promise<{ result: ParityResult; images?: ParityImages }> {
  const def = await loadPaintDef(item.paintMaterial);
  if (!def) return { result: { id: item.id, status: "error", wears: [], score: 0, error: "paint definition did not load" } };
  const weapon = await loadWeaponInputs(item.model, item.legacy);
  const comboId = valveComboId(def, weapon);
  const combo = await loadValveCombo(comboId);
  if (!combo) {
    return {
      result: { id: item.id, status: "nocombo", combo: comboId, style: def.style, wears: [], score: 0, error: `combo ${comboId} not bundled — see tools/valve-combos/README.md` },
    };
  }
  const wears = [...new Set([0, ...opts.wears, ...(opts.imagesAt != null ? [opts.imagesAt] : [])])].sort((a, b) => a - b);
  const frames = new Map<number, { ours: Frame; valve: Frame }>();
  let notes: ValveRefNotes | undefined;
  let images: ParityImages | undefined;
  let path: "valve" | "port" | undefined;
  const { withSharedRenderer } = await viewer3d();
  try {
    await withSharedRenderer(async (THREE, renderer) => {
      for (const wear of wears) {
        const comp = await compositePaint(THREE, renderer, def, {
          wear,
          seed: opts.seed,
          weapon,
          model: item.model,
          maxSize: opts.size,
          forcePort: opts.forcePort,
          reference: async (ctx) => {
            const ref = await renderValveReference(ctx, combo);
            try {
              notes ??= ref.notes;
              path ??= ctx.path;
              const ours = { albedo: await readRT(ctx, ctx.albedoRT), rm: await readRT(ctx, ctx.rmRT) };
              const valve = { albedo: await readRT(ctx, ref.albedoRT), rm: await readRT(ctx, ref.rmRT) };
              frames.set(wear, { ours, valve });
              if (opts.imagesAt === wear) {
                const s = ctx.size;
                images = {
                  wear,
                  ours: toDataUrl(ours.albedo, s),
                  valve: toDataUrl(valve.albedo, s),
                  diff: toDataUrl(ours.albedo, s, (_px, i, out) => {
                    const d = Math.max(
                      Math.abs(ours.albedo[i] - valve.albedo[i]),
                      Math.abs(ours.albedo[i + 1] - valve.albedo[i + 1]),
                      Math.abs(ours.albedo[i + 2] - valve.albedo[i + 2]),
                    );
                    // Red where it would read as wrong, dim grey for noise.
                    out[0] = d > VISIBLE ? 255 : d * 3;
                    out[1] = d > VISIBLE ? 40 : d * 3;
                    out[2] = d > VISIBLE ? 40 : d * 3;
                    out[3] = 255;
                  }),
                  // Rough/metal as (rough, metal, 0) in both, so they read alike.
                  oursRm: toDataUrl(ours.rm, s, (px, i, out) => {
                    out[0] = px[i + 1];
                    out[1] = px[i + 2];
                    out[2] = 0;
                    out[3] = 255;
                  }),
                  valveRm: toDataUrl(valve.rm, s, (px, i, out) => {
                    out[0] = px[i];
                    out[1] = px[i + 1];
                    out[2] = 0;
                    out[3] = 255;
                  }),
                };
              }
            } finally {
              ref.dispose();
            }
          },
        });
        comp?.release();
        // Hand the shared renderer back to any live viewer between passes.
        await yieldTask();
      }
    });
  } catch (e) {
    return { result: { id: item.id, status: "error", combo: comboId, style: def.style, wears: [], score: 0, error: e instanceof Error ? e.message : String(e) } };
  } finally {
    // Weapon inputs and the two shared wear/grunge sheets are what the next
    // finish reuses; everything else was this skin's alone.
    await evictPaintTextures((url) => url.includes("/models/") || /paint_wear|gun_grunge/.test(url));
  }
  const base = frames.get(0);
  if (!base) return { result: { id: item.id, status: "error", combo: comboId, style: def.style, wears: [], score: 0, error: "no frames rendered" } };
  const out = wears
    .filter((w) => w !== 0 || opts.wears.includes(0))
    .map((w) => {
      const f = frames.get(w)!;
      return compare(f.ours, f.valve, base.ours, base.valve, w);
    });
  return {
    result: {
      id: item.id,
      status: "ok",
      combo: comboId,
      style: def.style,
      path,
      wears: out,
      score: Math.max(0, ...out.map((w) => w.visibly)),
      notes,
    },
    images,
  };
}
