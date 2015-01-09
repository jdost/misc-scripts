# Wallpapers

Requirements:
- `feh`
- `python`

## `wallpaper.sh`

Will randomly choose a wallpaper from the folder specified by `$WP_FOLDER` and
a symlink to that wallpaper as `$CURRENT`.  Then will set the new picture as the
desktop wallpaper using `feh`.  Can take a second argument to run the update script
or give a count of images.

## `imgur_update.py`

This is a script that I use to "sync" my wallpaper collection between computers, it
pulls the images contained in an imgur album I maintain and only pulls the images
not already on the computer (does not currently delete).  Uses standard python
libraries so no need for much containment.

## `color_gen.py`
This is a script I have taken from: 
http://charlesleifer.com/blog/using-python-and-k-means-to-find-the-dominant-colors-in-images/.
It takes the image located at `WALLPAPER` and generates a colorscheme using a k-means
algorithm to find the 16 most dominant colors.  The colors are then stored in a
filename under the `XCOLORS` directory using the original filename of the image (so
not `Current` but whatever that symlinks to).

I have this disabled right now as the colorschemes generated are usually pretty dull
as my wallpaper choices are predominantly dominated by a single color and the 
generated colorschemes reflect this.  There could be some work done in trying to
bias the generated colors against a set palette.
