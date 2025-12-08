import sys
import math

# D65 White Point
XN = 95.047
YN = 100.000
ZN = 108.883
E = 0.008856
K = 903.3


def hex_to_rgb(h):

    h = h.lstrip('#')
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))


def rgb_to_xyz(r, g, b):

    r /= 255.0
    g /= 255.0
    b /= 255.0

    if r > 0.04045:
        r = ((r + 0.055) / 1.055)**2.4
    else:
        r /= 12.92

    if g > 0.04045:
        g = ((g + 0.055) / 1.055)**2.4
    else:
        g /= 12.92

    if b > 0.04045:
        b = ((b + 0.055) / 1.055)**2.4
    else:
        b /= 12.92

    r *= 100
    g *= 100
    b *= 100

    X = r * 0.4124 + g * 0.3576 + b * 0.1805
    Y = r * 0.2126 + g * 0.7152 + b * 0.0722
    Z = r * 0.0193 + g * 0.1192 + b * 0.9505

    return (X, Y, Z)


def xyz_to_lab(x, y, z):

    x /= XN
    y /= YN
    z /= ZN

    def f(t):
        if t > E:
            return math.pow(t, 1 / 3)
        else:
            return (K * t + 16) / 116

    fx = f(x)
    fy = f(y)
    fz = f(z)

    L = (116 * fy) - 16
    a = 500 * (fx - fy)
    b = 200 * (fy - fz)

    return (L, a, b)


def calculer_distance_delta_e_76(hex1, hex2):

    r1, g1, b1 = hex_to_rgb(hex1)
    r2, g2, b2 = hex_to_rgb(hex2)

    x1, y1, z1 = rgb_to_xyz(r1, g1, b1)
    l1, a1, b_val1 = xyz_to_lab(x1, y1, z1)

    x2, y2, z2 = rgb_to_xyz(r2, g2, b2)
    l2, a2, b_val2 = xyz_to_lab(x2, y2, z2)

    delta_e = math.sqrt((l1 - l2)**2 + (a1 - a2)**2 + (b_val1 - b_val2)**2)
    return delta_e


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.stderr.write(
            "Usage: python dist_pure.py <HEX_CODE_1> <HEX_CODE_2>\n")
        sys.exit(1)

    code1 = sys.argv[1].lstrip('#')
    code2 = sys.argv[2].lstrip('#')

    distance_calculee = calculer_distance_delta_e_76(code1, code2)

    print(f"{distance_calculee}")
