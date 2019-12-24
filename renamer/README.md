# Document Renamer

Simple HTTP app that provides a simple UI for categorizing and naming
document scans into a final location.  This is mostly to help standardize
and quickly store scanned documents using a simple naming scheme.

## Setup

Uses python3, so something like:
```
$ python3 -m venv venv/
$ ./venv/bin/python -m pip install -r requirements.txt
$ ./venv/bin/python renamer.py /mnt/scanner_sdcard /data/documents
...
```

Then just open up http://127.0.0.1:5000/ in a browser.

## Capabilities

Creates subfolders as needed based on category of the document.  Handles
naming conflicts as if the document is a paged document.  Provides some
basic rotation options (for fixing weird scans) using Pillow.
