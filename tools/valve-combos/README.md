# Valve compositor combos

`src/valveCombos/` holds Valve's own skin compositor — `csgo_customweapon.vfx`'s
pixel shader — decompiled to GLSL, one file per **static combo** a catalog
finish actually uses, plus a JSON sidecar per combo. `src/valveReference.ts`
runs them in WebGL2: it IS the production compositor (`compositePaint` renders
every finish with a bundled combo through it), and in oracle mode it is what
the **Valve parity** panel on the admin *Skin Tests* tab diffs against — either
the runtime (a difference = a wiring bug) or the hand port in
`src/paintComposite.ts`, which now only renders as a fallback.

That is the answer to "is every skin's wear right?" without paging through
2000 finishes by eye: the panel ranks finishes by how much of the atlas our
port gets wrong, and shows how much each side strips at each float.

## What a combo is

The shader is compiled once per combination of 11 static features. The id is
the sum of `value × multiplier` (VCS 72, from the program's StaticComboArray):

| feature | × |
|---|---|
| S_PAINT_STYLE (0–8) | 1 |
| S_OVERRIDE_NORMAL | 9 |
| S_USE_ALL_MASKS | 18 |
| S_ROUGHNESS_TEXTURE | 36 |
| S_PEARLESCENCE_MASK | 72 |
| S_METALNESS_TEXTURE | 144 |
| S_SEPARATE_CHANNEL_INPUTS | 288 |
| S_OVERLAY_TEXTURE | 576 |
| S_CASE_HARDENING | 1152 |
| S_CASE_HARDENING_TRILINEAR | 2304 |
| S_PATINA_AGE | 4608 |

1152 combos exist; the catalog (2012 weapon + knife finishes) uses 65. 82 are
bundled (~1.6MB of GLSL across lazy chunks — a finish fetches only its own).
`valveComboId()` in valveReference.ts picks the combo for a finish from the
material's F_* values AFTER its vcompmat SET_VALUE mutators ran — that is how
the game picks it (`g_bLegacyPatina=True` sets `F_PATINA_AGE=0`, and so on);
taking F_* from the template alone lands some finishes on the wrong combo.

The sidecar (`cNNNNN.json`) carries what binding needs and the GLSL does not
say: the sRGB-read flag of each texture *variant* that combo binds (g_tPattern
is linear for mask styles and sRGB for artwork styles — same name, different
variable), and each other variable's shader default and CPU-side Expression
(`1-x`, `SrgbGammaToLinear(x)`, the albedo-levels encode, `FEAT[n]`...).

## Regenerating (after a CS2 update, or for a combo the panel says is missing)

The panel reports a finish whose combo is not bundled as **no combo**, with the
id (and the runtime renders it with the hand port meanwhile). To add it, or to
refresh everything after the game ships new shaders, run the steps below — then
bump `VALVE_RUNTIME_REV` in valveReference.ts so every stored composite
re-bakes, and clear the card renders (admin cache, `renders`).

```sh
# 1. VRF from master — the 19.x release cannot read VCS 72.
git clone --depth 1 https://github.com/ValveResourceFormat/ValveResourceFormat tools/valve-combos/vrf

# 2. The three .vcs files, by byte range off the backend pod's game mount.
./tools/valve-combos/pull-vcs.sh /tmp/vcs

# 3. Decompile. With an id list, only those combos; without, all 1152 (~22MB —
#    do that into a scratch dir, never into src/).
cd tools/valve-combos
dotnet run -c Release -- /tmp/vcs/csgo_customweapon_vulkan_50_ps.vcs ../../src/valveCombos 6,292,1447
```

`vrf/` and `bin/` / `obj/` are scratch — don't commit them.

The vertex shader (`csgo_customweapon_vulkan_50_vs.vcs`) is not bundled: every
combo of it is four affine transforms of the mesh UV, `dot(uv, X.xy) + X.w`,
and valveReference.ts writes that by hand with our transforms fed in.

## Conversion

VRF emits Vulkan GLSL 460. `toWebGL2()` makes it GLSL ES 3.00 mechanically —
hoists the `_Globals_` block into plain uniforms, turns separate
`texture2D`/`sampler` pairs into `sampler2D`s (sampler STATE goes onto the
three Texture instead), drops `layout(location)` on fragment inputs, defines
`saturate`. The shader body is never edited. If a future decompile uses
something ES 3.00 lacks, it fails to compile loudly in the console rather than
rendering something plausible.

## What the oracle shares with our port, and what it does not

Independent: uniform values (raw authored params put through Valve's
Expressions), texture colour space and sampler state (from the combo's own
declarations), and all shader math.

Shared: which URL is which texture, and the seed → UV transform pipeline
(`seededVisuals` / `texXform`, verified bit-exact separately). A bug there
would be invisible to the parity check.
