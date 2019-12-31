#!/usr/bin/python
""" A task execution script for migrating newly dropped in wallpaper images
into the lookup file and download directory.  This is run on a cronjob that
just migrates the random assortment of image URL lists in the drop folder and
processes the images listed, this means cleaning up the names, downloading
the images, and updating the index listing.
"""
import os
import os.path as p
from base64 import b64encode
from hashlib import md5
from urllib import urlretrieve
import json


DROP_FOLDER = os.getenv("WALLPAPER_DROP", "/tmp/wallpapers")
WALLPAPER_FOLDER = os.getenv("WALLPAPER_FOLDER", "/home/wallpapers")


def check_drop():
    image_urls = []
    for url_file in os.listdir(DROP_FOLDER):
        filename = p.join(DROP_FOLDER, url_file)
        urls = file(filename, "r")
        for url in urls:
            image_urls.append(url)
        urls.close()
        os.remove(filename)

    return image_urls


def gen_filename(url):
    if not len(url):
        return False

    hsh_full = b64encode(md5(url).hexdigest())
    _, ext = url.rstrip().rsplit('.', 1)

    hsh = hsh_full[-8:]
    while p.isfile(p.join(WALLPAPER_FOLDER, ".".join([hsh, ext]))):
        hsh_full = hsh_full[:-1]
        hsh = hsh_full[-8:]

    return p.join(WALLPAPER_FOLDER, ".".join([hsh, ext]))


def get_image(url, location):
    url = url if url.startswith("http") else ("http:" + url)
    urlretrieve(url, location)


def gen_json():
    image_list = os.listdir(WALLPAPER_FOLDER)
    if "list.json" in image_list:
        image_list.remove("list.json")

    json_filename = p.join(WALLPAPER_FOLDER, "list.json")
    json_file = file(json_filename, "w")
    json.dump(image_list, json_file)
    json_file.close()


if __name__ == "__main__":
    images = check_drop()
    for image in images:
        image = image.strip()
        filename = gen_filename(image)
        if filename:
            get_image(image, filename)

    gen_json()
