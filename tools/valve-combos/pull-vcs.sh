#!/usr/bin/env bash
# Copy csgo_customweapon_vulkan_50_{ps,vs,features}.vcs off the game mount the
# inventory backend sees, by byte range — the archives are hundreds of MB and
# only ~6MB of them is wanted.
#
#   ./tools/valve-combos/pull-vcs.sh <outDir>
#
# Uses the 5stack cluster kubeconfig explicitly; read-only (`cat` / `dd`).
set -euo pipefail
OUT=${1:?outDir}
HERE=$(cd "$(dirname "$0")" && pwd)
KC=${KUBECONFIG_5STACK:-$HOME/.kube/5stackgg}
NS=5stack
CORE=/cs2-game/game/csgo_core
k() { KUBECONFIG=$KC kubectl -n $NS "$@"; }

POD=$(k get pods -o name | grep -E 'inventory-backend' | head -1 | sed 's|pod/||')
[ -n "$POD" ] || { echo "no inventory-backend pod" >&2; exit 1; }
mkdir -p "$OUT"
k exec "$POD" -c inventory-backend -- cat "$CORE/shaders_vulkan_dir.vpk" > "$OUT/shaders_vulkan_dir.vpk"

python3 -I "$HERE/vpkdir.py" "$OUT/shaders_vulkan_dir.vpk" csgo_customweapon_vulkan_50_ | while read -r path arch offs len; do
  [ "$len" -gt 0 ] || continue
  name=$(basename "$path")
  archive=$(printf '%s/shaders_vulkan_%03d.vpk' "$CORE" "$arch")
  k exec "$POD" -c inventory-backend -- dd if="$archive" bs=64k iflag=skip_bytes,count_bytes skip="$offs" count="$len" status=none > "$OUT/$name"
  echo "$name $(wc -c < "$OUT/$name") bytes (archive $arch @ $offs)"
done
