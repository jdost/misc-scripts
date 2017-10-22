#!/usr/bin/python2
from os import getenv, listdir
from os.path import join
from urllib import urlretrieve
from urllib2 import urlopen
import json

FOLDER = getenv("WALLPAPER_FOLDER", join(getenv("HOME"), ".wallpapers"))
URL_BASE = "http://wallpapers.jdost.us/{}"
IMG_EXT = ["." + ext for ext in ["jpg", "jpeg", "png", "gif"]]


def get_img(url):
    fn = url.split('/')[-1]
    url = url if url.startswith("http") else ("http:" + url)
    print "Downloading {} to {}".format(url, fn)
    urlretrieve(url, join(FOLDER, fn))

if __name__ == '__main__':
    images_raw = urlopen(URL_BASE.format("list.json"))
    images = dict(map(
        lambda x: (x, URL_BASE.format(x)), json.load(images_raw)))

    for wp in listdir(FOLDER):
        if not any([lambda ext: wp.endswith(ext) for ext in IMG_EXT]):
            continue
        if wp in images:
            del images[wp]

    for url in images.values():
        url = "http:" + url if not url.startswith("http") else url
        get_img(url)
