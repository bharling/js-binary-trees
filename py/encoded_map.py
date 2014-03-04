from noise import pnoise2, snoise2
from PIL import Image
import math

from pgt import Vector4, Vector3


mult = Vector4(1.0/255.0, 1.0/255.0, 1.0/255.0, 0.0)
divisor = Vector4(1.0, 255.0, 65025.0, 160581375.0)

def frac(ar):
    return Vector4(ar.x - math.floor(ar.x), ar.y - math.floor(ar.y), ar.z - math.floor(ar.z), ar.w - math.floor(ar.w))

def vecsub(a, b):
    return [a[0]-b[0], a[1]-b[1], a[2]-b[2], a[3]-b[3]]

def vecmul(a, b):
    return [a[0] * b[0], a[1] * b[1], a[2] * b[2], a[3] * b[3]]

def vec2pixel( v ):
    return [int(x * 255.0) for x in v]

def swizzle_yzww( ar ):
    return Vector4( ar.y, ar.z, ar.w, ar.w )

def encodeFloat(v):
    enc = divisor.mulScalar(v)
    enc = frac(enc)
    enc = enc - ( swizzle_yzww( enc ) * mult)
    return vec2pixel( enc )


def create_noise_map(size, freq, octaves):
    nmap = []
    freq *= octaves
    for x in range(size):
        for y in range(size):
            nmap.append(snoise2(x/freq, y/freq, octaves))
    return nmap


def getHeightValue(hmap, u, v, size):
    if u < 0:
        u = size-1
    if u > size-1:
        u = 0
    if v < 0:
        v = size-1
    if v > size-1:
        v = 0
    return hmap[u + (v*size)]



def computeNormal(hmap, u, v, size):
    scale = 150.0 / 16.0
    
    tl = getHeightValue(hmap, u-1, v-1, size)
    l = getHeightValue(hmap, u-1, v, size)
    bl = getHeightValue(hmap, u-1, v+1, size)
    b = getHeightValue(hmap, u, v+1, size)
    br = getHeightValue(hmap, u+1, v+1, size)
    r = getHeightValue(hmap, u+1, v, size)
    tr = getHeightValue(hmap, u+1, v-1, size)
    t = getHeightValue(hmap, u, v-1, size)
    
    dX = tr + 2 * r + br - tl - 2 * l - bl
    dY = bl + 2 * b + br - tl - 2 * t - tr
    
    N = Vector3(dX, dY, 1.0/scale).normalize()
    
    return N
    
    
    
def calculate_normals(noise_map, size):
    normals = []
    for x in range(size):
        for y in range(size):
            normals.append(computeNormal(noise_map, y, x, size))
    return normals


def loadrg(v):
    r,g = v
    return r/255.0, g/255.0

def storerg(v):
    r,g = v
    return int(r*255), int(g*255)

def floatToRG(f):
    toFixed = 255.0/256
    return frac(f*toFixed*1), frac(f*toFixed*255)

def rgToFloat(v):
    r,g = v
    fromFixed = 256.0/255
    return r*fromFixed/1 + g*fromFixed/(255)

def load(v):
    r,g,b,a = v
    return r/255.0, g/255.0, b/255.0, a/255.0

def store(v):
    r,g,b,a = v
    return int(r*255), int(g*255), int(b*255), int(a*255)

def frac(f):
    return f - int(f)

def floatToFixed(f):
    toFixed = 255.0/256
    return frac(f*toFixed*1), frac(f*toFixed*255), frac(f*toFixed*255*255), frac(f*toFixed*255*255*255)

def fixedToFloat(v):
    r,g,b,a = v
    fromFixed = 256.0/255
    return r*fromFixed/1 + g*fromFixed/(255) + b*fromFixed/(255*255) + a*fromFixed/(255*255*255)

def main():
    dims = 257 * 4
    noise_map = create_noise_map(dims, 32.0, 16)
    normal_map = calculate_normals(noise_map, dims)
    img = Image.new('RGBA', (dims, dims))
    for x in range(dims):
        for y in range(dims):
            normal = normal_map[x + (y*dims)]
            h = noise_map[x + (y*dims)] * 127.5 + 128
            R,G = storerg(floatToRG( noise_map[x+(y*dims)] * 0.5 + 0.5 ))
            img.putpixel((x,y), (R,G,0,255))
            #img.putpixel((x,y), (int(normal.x * 127.5 + 128), int(normal.y * 127.5 + 128), int(normal.z * 127.5 + 128 ), int(h)))
    img.save('heightmap.png', 'PNG')


if __name__=='__main__':
    print rgToFloat(loadrg(storerg(floatToRG(1.0))))
    print fixedToFloat(load(store(floatToFixed(0.0))))
    print fixedToFloat(load(store(floatToFixed(0.5))))
    print fixedToFloat(load(store(floatToFixed(1.0/3))))
    
    main()
    

    
    
#     dims = 257 * 4
# 
#     
#     img = Image.new('RGBA', (dims,dims))
#     octaves = 4
#     freq = 128.0 * octaves
#     
#     noise_map = []
#     
#     
#     for y in range(dims):
#         for x in range(dims):
#             n = snoise2(x / freq, y / freq, octaves)
#             noise_map.append(n)
#             #pix = encodeFloat(n)
#             #img.putpixel((x,y), tuple(pix))
#     #img.save("test.png", "PNG")
