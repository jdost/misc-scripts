# source: http://charlesleifer.com/blog/using-python-and-k-means-to-find-the-dominant-colors-in-images/
from collections import namedtuple
from math import sqrt
import random
try:
    import Image
except ImportError:
    from PIL import Image

Point = namedtuple('Point', ('coords', 'n', 'ct'))
Cluster = namedtuple('Cluster', ('points', 'center', 'n'))


def get_points(img):
    points = []
    w, h = img.size
    for count, color in img.getcolors(w * h):
        points.append(Point(color, 3, count))
    return points

rtoh = lambda rgb: '#%s' % ''.join(('%02x' % p for p in rgb))


def colorz(filename, n=3):
    img = Image.open(filename)
    img.thumbnail((200, 200))
    w, h = img.size

    points = get_points(img)
    clusters = kmeans(points, n, 1)
    rgbs = [map(int, c.center.coords) for c in clusters]
    return map(rtoh, rgbs)


def euclidean(p1, p2):
    return sqrt(sum([
        (p1.coords[i] - p2.coords[i]) ** 2 for i in range(p1.n)
    ]))


def calculate_center(points, n):
    vals = [0.0 for i in range(n)]
    plen = 0
    for p in points:
        plen += p.ct
        for i in range(n):
            vals[i] += (p.coords[i] * p.ct)
    return Point([(v / plen) for v in vals], n, 1)


def kmeans(points, k, min_diff):
    clusters = [Cluster([p], p, p.n) for p in random.sample(points, k)]

    while 1:
        plists = [[] for i in range(k)]

        for p in points:
            smallest_distance = float('Inf')
            for i in range(k):
                distance = euclidean(p, clusters[i].center)
                if distance < smallest_distance:
                    smallest_distance = distance
                    idx = i
            plists[idx].append(p)

        diff = 0
        for i in range(k):
            old = clusters[i]
            center = calculate_center(plists[i], old.n)
            new = Cluster(plists[i], center, old.n)
            clusters[i] = new
            diff = max(diff, euclidean(old.center, new.center))

        if diff < min_diff:
            break

    return clusters

# This is the stuff I wrote, adapted from []
import colorsys
import os.path
import os
import sys

WALLPAPER = "~/.wallpapers/Current"
XCOLORS = "~/.config/X11/xcolors/"


def set_file(src):
    return
    #symlink = os.path.join(XCOLORS, "Current")
    #os.remove(symlink)
    #os.symlink(src, symlink)


def fit(src, minv, maxv):
    dst = minv if src < minv else src
    return maxv if src > maxv else dst


def normalize(hex_color, v=(0, 256), r=(0,256), g=(0,256), b=(0,256)):
    hex_color = hex_color[1:]
    vrange = (v[0]/256.0, v[1]/256.0)
    rrange = (r[0]/256.0, r[1]/256.0)
    grange = (g[0]/256.0, g[1]/256.0)
    brange = (b[0]/256.0, b[1]/256.0)

    r, g, b = (
        int(hex_color[:2], 16)/256.0,
        int(hex_color[2:4], 16)/256.0,
        int(hex_color[4:], 16)/256.0
    )
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    v = fit(v, vrange[0], vrange[1])

    r, g, b = colorsys.hsv_to_rgb(h, s, v)
    r = fit(r, rrange[0], rrange[1])
    g = fit(g, grange[0], grange[1])
    b = fit(b, brange[0], brange[1])

    return "#{:02x}{:02x}{:02x}".format(int(r*256), int(g*256), int(b*256))

color_limits = [
    { "v": (0, 32) },       # black
    { "v": (160, 224) },    # red
    { "v": (160, 224) },    # green
    { "v": (160, 224) },    # yellow
    { "v": (160, 224) },    # blue
    { "v": (160, 224) },    # magenta
    { "v": (160, 224) },    # cyan
    { "v": (160, 224) },    # white
    { "v": (128, 192) },    # light black
    { "v": (200, 256) },    # light red
    { "v": (200, 256) },    # light green
    { "v": (200, 256) },    # light yellow
    { "v": (200, 256) },    # light blue
    { "v": (200, 256) },    # light magenta
    { "v": (200, 256) },    # light cyan
    { "v": (200, 256) }     # light white
]

if __name__ == '__main__':
    WALLPAPER = os.path.expanduser(WALLPAPER)
    XCOLORS = os.path.expanduser(XCOLORS)

    (basename, _) = os.path.splitext(os.path.basename(
        os.path.realpath(WALLPAPER)))
    tgt_xcolor = os.path.join(XCOLORS, "wallpapers", basename+".xcolors")

    if os.path.exists(tgt_xcolor):
        set_file(tgt_xcolor)
        sys.exit(0)

    colors = colorz(WALLPAPER, n=16)

    for i in range(len(colors)):
        colors[i] = normalize(colors[i], **color_limits[i])

    with open(tgt_xcolor, "w") as f:
        f.write("""*background: {}\n""".format(colors[0]))
        f.write("""*foreground: {}\n\n""".format(colors[15]))
        for i in range(len(colors)):
            f.write("""*color{}: {}\n""".format(i, colors[i]))

        f.close()

    set_file(tgt_xcolor)
