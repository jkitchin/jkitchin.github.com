# Generate web pages for the publications in a bibtex file.

import os
from blogofile.cache import bf

config = {"name"        : "Publication gallery",
          "description" : "Generates html pages from bibtex entries."
          }

photos_dir = os.path.join("img")


def run():
    photos = read_photos()
    print '*****************************  photos = ', photos
    write_pages(photos)
    write_photo_index(photos)


def read_photos():
    # This could be a lot more advanced, like supporting subfolders, creating
    # thumbnails, and even reading the Jpeg EXIF data for better titles and
    # such. This is kept simple for demonstration purposes.
    return [p for p in os.listdir(photos_dir) if p.lower().endswith(".png")]


def write_pages(photos):
    for photo in photos:
        print '######################### {}'.format(photo)
        bf.template.materialize_template("photo.mako",
                                         (photos_dir, photo + ".html"),
                                         {"photo": photo})


def write_photo_index(photos):
    bf.template.materialize_template("photo_index.mako", (photos_dir,
                                                          "index.html"),
                                     {"photos": photos})
