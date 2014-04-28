#!/usr/bin/python2
from HTMLParser import HTMLParser
from os import getenv, listdir
from os.path import join, splitext
from urllib import urlretrieve, urlopen

FOLDER = getenv("WALLPAPER_FOLDER", join(getenv("HOME"), ".wallpapers"))
ALBUM_BASE = "http://imgur.com/a/SP32s/all/page/{}?scrolled"


class ListParser(HTMLParser):
    ''' Parses the HTML output of the page retrieval for the imgur album, at
    ever div, the id is stored and when a child is a link (this should be a
    link to the full image), the link is stored against the id.  Also detects
    if there are more pages in the album.'''
    def __init__(self, *args, **kwargs):
        self.images = {}
        self.end = False
        self.current_id = None

        HTMLParser.__init__(self, *args, **kwargs)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)

        if tag == 'a' and self.current_id:
            self.images[self.current_id] = attrs['href']
        elif tag == 'div':
            if attrs.get('id', None) == 'nomore':
                self.end = True
            else:
                self.current_id = attrs.get('id', None)

    def handle_endtag(self, tag):
        if tag == 'div':
            self.current_id = None


def get_img(url):
    fn = url.split('/')[-1]
    url = url if url.startswith("http") else ("http:" + url)
    print "Downloading {} to {}".format(url, fn)
    urlretrieve(url, join(FOLDER, fn))

if __name__ == '__main__':
    page = 0
    parser = ListParser()

    while True:
        test = urlopen(ALBUM_BASE.format(page))
        parser.feed(test.read())
        test.close()

        if parser.end:
            break
        page += 1

    images = parser.images

    for wp in listdir(FOLDER):
        if not wp.endswith(".jpg") and not wp.endswith(".png"):
            continue
        name, ext = splitext(wp)
        if name in images:
            del images[name]

    for url in images.values():
        url = "http:" + url if not url.startswith("http") else url
        get_img(url)
