import random
import re
import sys

from pathlib import Path
from typing import List, Optional

from flask import Flask, redirect, render_template, request, url_for
from PIL import Image

if len(sys.argv) < 3:
    print("Usage: {sys.argv[0]} <unsorted documents> <destination folder>")
    sys.exit(1)

TARGET_FOLDER = Path(sys.argv[2])
TRANSPOSING_LOOKUP = {
    '90': Image.ROTATE_90,
    '180': Image.ROTATE_180,
    '270': Image.ROTATE_270,
}
UNSORTED_FOLDER = Path(sys.argv[1])
YEAR_REGEX = re.compile("^[0-9]{4}$")
app = Flask(__name__, static_url_path='/s', static_folder=UNSORTED_FOLDER)


def get_options() -> List[str]:
    """Get a list of all possible folders already created."""
    options: List[str] = []
    tree: List[Path] = [TARGET_FOLDER]

    def should_skip(folder: Path) -> bool:
        return (
            not folder.is_dir() or
            folder == UNSORTED_FOLDER or
            folder.name.startswith('#') or
            folder.name.startswith('.') or
            YEAR_REGEX.match(folder.name)
        )

    while len(tree):
        current = tree.pop(0)
        if should_skip(current):
            continue

        if current != TARGET_FOLDER:
            options.append(str(current.relative_to(TARGET_FOLDER)))

        for child in current.iterdir():
            if child.is_dir():
                tree.append(child)

    return options


@app.route('/', methods=['GET'])
def req():
    """Primary UI for viewing a document and providing a naming scheme."""
    images = sorted(
        list(UNSORTED_FOLDER.glob('*.JPG')) + \
        list(UNSORTED_FOLDER.glob('*.jpg'))
    )
    if len(images) == 0:
        return 200

    return render_template(
        'index.html',
        image=images[0].relative_to(UNSORTED_FOLDER),
        src_folder='s',
        options=get_options(),
        cache_buster=int(99999999*random.random()),
    )


@app.route('/', methods=['POST'])
def name_image():
    """Take the output from a submission on `req` and perform the renaming."""
    src = UNSORTED_FOLDER / request.form['src']

    filename = ''.join(
        [w.capitalize() for w in request.form['name'].split()]
    ) + ".jpg"
    year = request.form['year'].split('/')
    if len(year) > 1:
        filename = f"{''.join(year[1:])}.{filename}"

    dst = TARGET_FOLDER / request.form['dst'] / year[0] / filename
    if not dst.parent.exists() and not dst.parent.is_dir():
        print(f"CREATING: {dst.parent}")
        dst.parent.mkdir(parents=True)

    if dst.exists():
        pg_count = len(list(dst.parent.glob(dst.with_suffix("").name + "*")))
        dst = dst.parent / (
                dst.with_suffix("").name + f".{pg_count+1}" + dst.suffix
            )

    print(f"RENAMING: {src} -> {dst}")
    src.rename(dst)
    return redirect(url_for('req'))


@app.route('/transform', methods=['POST'])
def transform_image():
    """Rotate the image using the rotation buttons on the right."""
    img_path = UNSORTED_FOLDER / request.form['src']
    angle = request.form['angle']
    print(f"Rotating {img_path} {angle} degrees")

    img = Image.open(img_path)
    img.transpose(TRANSPOSING_LOOKUP[angle]).save(img_path)
    return redirect(url_for('req'))


if __name__ == "__main__":
    print(
        f"Serving on :5000 for documents in {UNSORTED_FOLDER} to be stored "
        f"in {TARGET_FOLDER}"
    )
    app.run(debug=True)
