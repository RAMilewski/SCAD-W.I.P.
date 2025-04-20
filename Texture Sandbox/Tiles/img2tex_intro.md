# Images as Textures

There is a Python script named [img2tex.py](https://github.com/BelfrySCAD/BOSL2/blob/master/scripts/img2tex.py) in the BOSL2 scripts folder that can process `.jpg`, `.gif`, or `.png` image files into data arrays suitable for use as textures.

While the script can process color images, the best results are generally obtained with line art or grayscale images.  

Because most image files produce very large data arrays, the `img2tex.py` script includes the ability to downscale the output, resulting in data arrays that render as textures in less time.

usage: img2tex [-h] [-o OUTFILE] [-v VARNAME] [-i] [-r RESIZE] [-R {-270,-180,-90,0,90,180,270}] [--mirror-x] [--mirror-y]
               [--blur BLUR] [--minout MINOUT] [--maxout MAXOUT] [--range {dynamic,full}]
               infile

| **Positional Argument**     | **Description**          |
|------------------------|-------------------------|
| `infile`              | Input image file.  |
|      |      |
| **Option**            | **Description**                                                         |
| `-h, --help`          | Show the help message and exit.                                          |
| `-o OUTFILE`          | Specify the output `.scad` file.                                         |
| `-v VARNAME`          | Set the variable name to use in the `.scad` file.                       |
| `-i, --invert`        | Invert luminance values.                                                |
| `-r RESIZE`           | Resample the image to `WIDTHxHEIGHT`.                                   |
| `-R {degrees}`        | Rotate the output by the specified degrees (`-270, -180, -90, 0, 90...`).|
| `--mirror-x`          | Mirror the output in the X direction.                                   |
| `--mirror-y`          | Mirror the output in the Y direction.                                   |
| `--blur BLUR`         | Apply a box blur with the given radius.                                 |
| `--minout MINOUT`     | Set the output value for the minimum luminance.                         |
| `--maxout MAXOUT`     | Set the output value for the maximum luminance.                         |
| `--range {dynamic}`   | Scale luminances dynamically or use the full range (`0-255`).           |
