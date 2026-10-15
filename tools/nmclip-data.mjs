// A CS2 `.vnmclip_c` decoded straight from its DATA block — including the
// tracks Source2Viewer's decompile throws away.
//
// WHY THIS EXISTS. A viewmodel clip animates TWO skeletons: the arms
// (`characters/viewmodel.vnmskel`) and the weapon's own prop skeleton
// (`weapons/<name>.vnmskel`), the second stored as `m_secondaryAnimations`.
// The CLI we ship (VRF 19.2) writes only the first into its DMX, so a knife's
// `weapon_offset` — which turns the blade in the fist — and a butterfly's
// `front`/`rear`/`blade` — which ARE the flip — never reached the viewer. The
// knife sat in the hand at its bind orientation and every knife inspect played
// with the knife frozen. VRF master does export them (NmClipExtract appends the
// secondary skeleton's joints to the same DMX), but this decodes the compiled
// data directly so the extraction does not hinge on which CLI is installed.
//
// THE FORMAT, as VRF's ModelAnimation2/AnimationClip.cs reads it:
//
//   m_compressedPoseData      uint16 stream, one run per frame
//   m_compressedPoseOffsets   where each frame's run starts, in uint16s
//   m_trackCompressionSettings  one per bone, in skeleton order:
//       rotation   static → m_constantRotation, else 3 uint16 "smallest three"
//       translation static → range starts, else 3 uint16 normalised in range
//       scale      static → range start, else 1 uint16
//
// Values come out RAW — no axis fixup. That is right for a prop skeleton (VRF
// only re-frames bones under `root_motion`, which a weapon skeleton has none
// of) and is checked against the DMX for the arm skeleton by `--verify`.

/**
 * Parse the KV3 TEXT that `Source2Viewer-CLI -b DATA` prints.
 *
 * Only the subset these files use: objects, arrays, `#[ hex ]` blobs,
 * `resource:"…"`, strings, numbers, booleans. Commas are separators AND may
 * trail (VRF writes `},` after every array element), so they are skipped
 * wherever they appear.
 */
export function parseKv3Text(text) {
  // After the header comment, which has braces of its own (`version{…}`).
  const start = text.indexOf("{", text.indexOf("-->", text.indexOf("<!-- kv3")));
  let i = start;
  const ws = () => {
    while (i < text.length) {
      const c = text[i];
      if (c === " " || c === "\t" || c === "\n" || c === "\r" || c === ",") i++;
      else if (c === "/" && text[i + 1] === "/") while (i < text.length && text[i] !== "\n") i++;
      else break;
    }
  };
  const value = () => {
    ws();
    const c = text[i];
    if (c === "{") {
      i++;
      const obj = {};
      for (;;) {
        ws();
        if (text[i] === "}") {
          i++;
          return obj;
        }
        const m = /^[A-Za-z_][\w.]*/.exec(text.slice(i, i + 200));
        if (!m) throw new Error(`kv3: bad key at ${i}: ${text.slice(i, i + 40)}`);
        i += m[0].length;
        ws();
        if (text[i] !== "=") throw new Error(`kv3: expected = at ${i}`);
        i++;
        obj[m[0]] = value();
      }
    }
    if (c === "[") {
      i++;
      const arr = [];
      for (;;) {
        ws();
        if (text[i] === "]") {
          i++;
          return arr;
        }
        arr.push(value());
      }
    }
    if (c === "#" && text[i + 1] === "[") {
      const end = text.indexOf("]", i);
      const hex = text.slice(i + 2, end).replace(/\s+/g, "");
      i = end + 1;
      return Buffer.from(hex, "hex");
    }
    if (c === '"') {
      const end = text.indexOf('"', i + 1);
      const s = text.slice(i + 1, end);
      i = end + 1;
      return s;
    }
    const m = /^(resource_name:|resource:|soundevent:|panorama:)?("([^"]*)"|[^\s,\]}]+)/.exec(text.slice(i, i + 400));
    if (!m) throw new Error(`kv3: bad value at ${i}: ${text.slice(i, i + 40)}`);
    i += m[0].length;
    if (m[3] !== undefined) return m[3];
    const raw = m[2];
    if (raw === "true") return true;
    if (raw === "false") return false;
    if (raw === "null") return null;
    const n = Number(raw);
    return Number.isFinite(n) ? n : raw;
  };
  return value();
}

const RANGE_MIN = -1 / Math.SQRT2;
const RANGE_LEN = 2 / Math.SQRT2;

/** VRF's DecodeQuaternion: smallest-three in 15 bits each, the dropped
 *  component's index in the two spare top bits. Returns [x, y, z, w]. */
function decodeQuat(u, o) {
  const a = (u[o] & 0x7fff) * (RANGE_LEN / 0x7fff) + RANGE_MIN;
  const b = (u[o + 1] & 0x7fff) * (RANGE_LEN / 0x7fff) + RANGE_MIN;
  const c = u[o + 2] * (RANGE_LEN / 0x7fff) + RANGE_MIN;
  const w = Math.sqrt(Math.max(0, 1 - (a * a + b * b + c * c)));
  const largest = ((u[o] >> 14) & 0x2) | (u[o + 1] >> 15);
  switch (largest) {
    case 0: return [w, a, b, c];
    case 1: return [a, w, b, c];
    case 2: return [a, b, w, c];
    default: return [a, b, c, w];
  }
}

const unorm = (v, start, len) => (v / 0xffff) * len + start;

/**
 * Decode one clip object (primary or a secondary) into per-bone tracks.
 *
 * Same shape `readClip` in nmclip.mjs returns, so the extractor's compaction
 * and JSON writing apply unchanged: `bones[name] = { rot, pos }`, each
 * `{ times, values: [[…], …] }`.
 */
export function decodeClip(clip, boneNames) {
  const frames = clip.m_nNumFrames;
  const duration = clip.m_flDuration;
  const settings = clip.m_trackCompressionSettings ?? [];
  const data = clip.m_compressedPoseData ?? Buffer.alloc(0);
  const u = new Uint16Array(data.buffer, data.byteOffset, data.byteLength >> 1);
  const offsets = clip.m_compressedPoseOffsets ?? [];
  // Frame times: evenly spread over the duration, first at 0 and last at the
  // end — the same spacing the DMX carries (VRF: duration = (frames-1)/fps).
  const times = Array.from({ length: frames }, (_, f) => (frames > 1 ? (f * duration) / (frames - 1) : 0));

  const bones = {};
  settings.forEach((s, b) => {
    const name = boneNames[b] ?? `#${b}`;
    bones[name] = { rot: { times, values: [] }, pos: { times, values: [] } };
  });
  for (let f = 0; f < frames; f++) {
    let o = offsets[f] ?? 0;
    settings.forEach((s, b) => {
      const name = boneNames[b] ?? `#${b}`;
      let rot = s.m_constantRotation;
      let pos = [s.m_translationRangeX.m_flRangeStart, s.m_translationRangeY.m_flRangeStart, s.m_translationRangeZ.m_flRangeStart];
      if (!s.m_bIsRotationStatic) {
        rot = decodeQuat(u, o);
        o += 3;
      }
      if (!s.m_bIsTranslationStatic) {
        pos = [
          unorm(u[o], s.m_translationRangeX.m_flRangeStart, s.m_translationRangeX.m_flRangeLength),
          unorm(u[o + 1], s.m_translationRangeY.m_flRangeStart, s.m_translationRangeY.m_flRangeLength),
          unorm(u[o + 2], s.m_translationRangeZ.m_flRangeStart, s.m_translationRangeZ.m_flRangeLength),
        ];
        o += 3;
      }
      if (!s.m_bIsScaleStatic) o += 1;
      bones[name].rot.values.push(rot);
      bones[name].pos.values.push(pos);
    });
  }
  return { duration, frames, bones };
}

/** Bone names and parents of a compiled `.vnmskel_c`, from its DATA dump. */
export function readSkeleton(skel) {
  const names = skel.m_boneIDs ?? [];
  const parents = {};
  (skel.m_parentIndices ?? []).forEach((p, b) => {
    if (p >= 0) parents[names[b]] = names[p];
  });
  return { names, parents };
}

/** The resource path inside `resource:"…"`, normalised to the compiled name. */
export const compiledPath = (res) => (res.endsWith("_c") ? res : `${res}_c`);
