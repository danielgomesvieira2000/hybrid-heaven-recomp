#!/usr/bin/env python3
"""Draw the launcher emblem and the executable icon from one set of polygons.

    python tools/make_logo.py            # writes assets/icons/Logo.svg and assets/AppIcon.ico

The artwork is original to this project and derived from nothing in the
cartridge: a faceted, flat-shaded crystal in the low-polygon style of the
period, wrapped in a twin helix ribbon (the "hybrid" of the title). It carries
no lettering, so the launcher keeps its own plain-text title (src/frontend.cpp).

Both outputs come from the same polygon list, so the icon cannot drift from
the launcher art. The SVG uses only <polygon> elements, because the menu's SVG
renderer (lunasvg) draws no <text>. The .ico is rasterised with Pillow at 4x and
downscaled per size with Lanczos (the sizes Windows asks for; see
n64recomp-claude_framework/tools/make-icon.py for why every size is written).
Needs Pillow only for the .ico.
"""

import io
import math
import struct
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
VIEW_W, VIEW_H = 680, 360
CX, CY = VIEW_W / 2, VIEW_H / 2

ICON_SIZES = [16, 20, 24, 32, 40, 48, 64, 128, 256]


def shade(rgb, k):
    return tuple(max(0, min(255, int(c * k))) for c in rgb)


def crystal(CX, CY):
    """A six-sided bipyramid seen slightly from above: upper and lower facets."""
    polys = []
    top = (CX, CY - 150)
    bottom = (CX, CY + 150)
    rx, ry = 92, 26
    base = (78, 70, 170)          # violet
    ring = []
    for i in range(6):
        a = math.radians(60 * i + 30)
        ring.append((CX + rx * math.cos(a), CY + ry * math.sin(a)))
    # Light from the upper left: a facet's brightness follows its outward direction.
    for i in range(6):
        p, q = ring[i], ring[(i + 1) % 6]
        mid_angle = math.radians(60 * i + 60)
        light = 0.62 + 0.38 * math.cos(mid_angle - math.radians(215))
        front = math.sin(mid_angle) > -0.2       # facets on the near side are drawn
        if front:
            polys.append(([top, p, q], shade(base, 1.05 * light + 0.15)))
            polys.append(([bottom, p, q], shade(base, 0.62 * light + 0.05)))
    return polys


def helix(CX, CY, swap):
    """Two ribbons winding around the crystal, split into flat quads."""
    polys = []
    colours = [(64, 200, 230), (236, 92, 150)]    # cyan, magenta
    if swap:
        colours.reverse()
    steps = 28
    height = 250
    radius = 150
    width = 9
    for strand in range(2):
        phase = math.pi * strand
        pts = []
        for s in range(steps + 1):
            t = s / steps
            y = CY - height / 2 + height * t
            ang = phase + t * 2.2 * math.pi
            x = CX + radius * math.sin(ang)
            depth = math.cos(ang)                 # > 0: in front of the crystal
            pts.append((x, y, depth))
        for s in range(steps):
            (x0, y0, d0), (x1, y1, d1) = pts[s], pts[s + 1]
            d = (d0 + d1) / 2
            k = 0.55 + 0.45 * (d + 1) / 2
            quad = [(x0, y0 - width), (x1, y1 - width), (x1, y1 + width), (x0, y0 + width)]
            polys.append((quad, shade(colours[strand], k), d))
    return polys


def emblem(cx=CX, cy=CY, scale=1.0, swap=False):
    """Back ribbon segments, crystal, front ribbon segments: painter's order.

    Drawn at the view centre and full size, then placed: (cx, cy) and scale."""
    ribbons = helix(CX, CY, swap)
    back = [(p, c) for p, c, d in ribbons if d <= 0]
    front = [(p, c) for p, c, d in ribbons if d > 0]
    out = []
    for poly, colour in back + crystal(CX, CY) + front:
        out.append(([(cx + (x - CX) * scale, cy + (y - CY) * scale) for x, y in poly], colour))
    return out


# The launcher lays this SVG out at the window's full width, vertically centred,
# behind its title (about 28% down) and its menu (a centred column). Two small
# emblems flank the column so neither overlaps text at 4:3 or 16:9.
LAUNCHER_SCALE = 0.55
LAUNCHER_X = 100


def launcher_scene():
    return (emblem(LAUNCHER_X, CY, LAUNCHER_SCALE, False) +
            emblem(VIEW_W - LAUNCHER_X, CY, LAUNCHER_SCALE, True))


def write_svg(path):
    parts = [f'<svg width="100%" viewBox="0 0 {VIEW_W} {VIEW_H}" role="img" '
             'xmlns="http://www.w3.org/2000/svg">',
             "<title>Hybrid Heaven: Recompiled</title>",
             "<desc>Two faceted low-polygon violet crystals, each wrapped in a cyan and magenta twin helix. "
             "Original artwork for this project.</desc>"]
    for poly, (r, g, b) in launcher_scene():
        pts = " ".join(f"{x:.1f},{y:.1f}" for x, y in poly)
        parts.append(f'<polygon points="{pts}" fill="#{r:02x}{g:02x}{b:02x}"/>')
    parts.append("</svg>")
    path.write_text("\n".join(parts) + "\n", encoding="utf-8", newline="\n")


def write_ico(path):
    from PIL import Image, ImageDraw

    big = 1024
    # Square crop around the emblem, which is taller than it is wide.
    side = 330.0
    ox, oy = CX - side / 2, CY - side / 2
    scale = big / side
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    for poly, colour in emblem():
        draw.polygon([((x - ox) * scale, (y - oy) * scale) for x, y in poly], fill=colour + (255,))

    entries = []
    for size in ICON_SIZES:
        buf = io.BytesIO()
        img.resize((size, size), Image.LANCZOS).save(buf, format="PNG")
        entries.append((size, buf.getvalue()))

    header = struct.pack("<HHH", 0, 1, len(entries))
    offset = 6 + 16 * len(entries)
    directory = b""
    data = b""
    for size, png in entries:
        dim = 0 if size >= 256 else size
        directory += struct.pack("<BBBBHHII", dim, dim, 0, 0, 1, 32, len(png), offset + len(data))
        data += png
    path.write_bytes(header + directory + data)


def main():
    svg = REPO / "assets" / "icons" / "Logo.svg"
    ico = REPO / "assets" / "AppIcon.ico"
    write_svg(svg)
    write_ico(ico)
    print(f"wrote {svg.relative_to(REPO)} and {ico.relative_to(REPO)}")


if __name__ == "__main__":
    main()
