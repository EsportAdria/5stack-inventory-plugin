# List entries of a VPK2 _dir.vpk whose path contains a substring, as
# "<path> <archive index> <offset> <length>" — enough to dd one file out of the
# multi-hundred-MB archives without copying them.
#   python3 vpkdir.py shaders_vulkan_dir.vpk customweapon
import struct
import sys

data = open(sys.argv[1], "rb").read()
sig, ver, tree = struct.unpack_from("<III", data, 0)
off = 28 if ver == 2 else 12
pat = sys.argv[2] if len(sys.argv) > 2 else ""


def cstr(p):
    e = data.index(b"\0", p)
    return data[p:e].decode("latin1"), e + 1


p = off
while True:
    ext, p = cstr(p)
    if not ext:
        break
    while True:
        path, p = cstr(p)
        if not path:
            break
        while True:
            name, p = cstr(p)
            if not name:
                break
            crc, preload, arch, offs, length, term = struct.unpack_from("<IHHIIH", data, p)
            p += 18 + preload
            full = f"{path}/{name}.{ext}"
            if pat in full:
                print(full, arch, offs, length)
