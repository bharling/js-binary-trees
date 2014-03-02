import argparse
from PIL import Image
import math

def getHeight(x,y,img):
    return img.getpixel((x,y))[0] / 255.0


def computeVariance( apexX, apexY, leftX, leftY, rightX, rightY, img ):
    heightA = getHeight(leftX, leftY, img)
    heightB = getHeight(rightX, rightY, img)
    avg = (heightA + heightB) / 2.0;
    centerX = (leftX + rightX)>>1
    centerY = (leftY + rightY)>>1
    heightC = getHeight(centerX, centerY, img)
    return math.fabs(heightC - avg)

def traverseVariance( apexX, apexY, leftX, leftY, rightX, rightY, img, depth, maxdepth ):
    v = computeVariance(apexX, apexY, leftX, leftY, rightX, rightY, img)
    centerX = (leftX + rightX)>>1
    centerY = (leftY + rightY)>>1
    if depth <= maxdepth:
        v = max(v, computeVariance( centerX, centerY, apexX, apexY, leftX, leftY, img ));
        v = max(v, computeVariance( centerX, centerY, rightX, rightY, apexX, apexY, img ));
    ret = "0"
    if v > 0.01:
        ret = "1"
    if ret == "0" or depth >= maxdepth:
        return "0"
    
    ret += traverseVariance( centerX, centerY, apexX, apexY, leftX, leftY, img, depth+1, maxdepth );
    ret += traverseVariance( centerX, centerY, rightX, rightY, apexX, apexY, img, depth+1, maxdepth );
    return ret;
    
    

def buildVarianceTree( img, max_lod = 4 ):
    imgWidth, imgHeight = img.size
    left = traverseVariance(0,0,0, imgHeight-1, imgWidth-1, 0, img, 0, max_lod)
    right = traverseVariance(imgWidth-1, imgHeight-1, imgWidth-1, 0, 0, imgHeight-1, img, 0, max_lod)
    return left + right


json_template = '\t{ \n\t\t"filename" : "%s", \n\t\t"variance": "%s",\n\t\t"low_detail": "%s",\n\t\t"x":%d,\n\t\t"y":%d  \n\t}'


def buildTiles( imgPath, size=257 ):
    img = Image.open(imgPath)
    width, height = img.size
    
    if not width % size == 0 or not height % size == 0:
        raise Exception("tile size does not fit the image")
    
    num_tiles = width / size
    
    tilesdata = []
    
    x = y = 0
    for x in range(num_tiles):
        for y in range(num_tiles):
            _x = x*size
            _y = y*size
            tile = img.crop((_x,_y,_x+size,_y+size))
            filename = "%d_%d.png" % ( x, y )
            tile.save(filename, 'PNG')
            print "building tree for %d x %d" % ( x,y )
            variance_hi = buildVarianceTree(tile, 10)
            variance_low = buildVarianceTree(tile, 6)
            tilesdata.append(json_template % (filename, variance_hi, variance_low, _x, _y))
    with open("data.json", "w") as f:
        f.write("[\n" + ",\n".join(tilesdata) + "\n]")
    
    

    
if __name__=="__main__":
    buildTiles("hm2.jpg")
    