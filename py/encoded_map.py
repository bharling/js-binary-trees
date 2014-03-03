from noise import pnoise2, snoise2
from PIL import Image
import math

mult = [1.0/255.0, 1.0/255.0, 1.0/255.0, 0.0]

def frac(ar):
    return [x - math.floor(x) for x in ar]

def vecsub(a, b):
    return [a[0]-b[0], a[1]-b[1], a[2]-b[2], a[3]-b[3]]

def vecmul(a, b):
    return [a[0] * b[0], a[1] * b[1], a[2] * b[2], a[3] * b[3]]

def vec2pixel( v ):
    return [int(x * 255.0) for x in v]

def swizzle_yzww( ar ):
    return [ar[1], ar[2], ar[3], ar[3]]

def encodeFloat(v):
    enc = [1.0 * v, 255.0 * v, 65025.0 * v, 160581375.0 *v]
    enc = frac(enc)
    enc = vecsub(enc, vecmul( swizzle_yzww( enc ), mult) )
    return vec2pixel( enc )


if __name__=='__main__':
    dims = 257 * 2

    
    img = Image.new('RGBA', (dims,dims))
    octaves = 4
    freq = 16.0 * octaves
    for y in range(dims):
        for x in range(dims):
            n = snoise2(x / freq, y / freq, octaves)
            pix = encodeFloat(n)
            img.putpixel((x,y), tuple(pix))
    img.save("test.jpg", "JPEG")
