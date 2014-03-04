import random
from libc.math cimport sqrt, acos
from Quaternion cimport Quaternion

# portions of this code adapted from
# https://code.google.com/p/pyeuclid


cdef class Vector4:
    
    @classmethod
    def random(cls):
        return cls(random.uniform(-1.0, 1.0), random.uniform(-1.0, 1.0), random.uniform(-1.0, 1.0), random.uniform(-1.0, 1.0))
    
    @classmethod
    def zero(cls):
        return cls(0.0, 0.0, 0.0, 0.0)
    
    @classmethod
    def ones(cls):
        return cls(1.0, 1.0, 1.0, 1.0)
    
    @classmethod
    def unit_z(cls):
        return cls(0.0, 0.0, 1.0, 1.0)
    
    @classmethod
    def unit_x(cls):
        return cls(1.0, 0.0, 0.0, 0.0)
    
    @classmethod
    def unit_y(cls):
        return cls(0.0, 1.0, 0.0, 0.0)
    
    @classmethod
    def neg_unit_x(cls):
        return cls(-1.0, 0.0, 0.0, 0.0)
    
    @classmethod
    def neg_unit_y(cls):
        return cls(0.0, -1.0, 0.0, 0.0)
    
    @classmethod
    def neg_unit_z(cls):
        return cls(0.0, 0.0, -1.0, 0.0)
    
    @classmethod
    def unit_w(cls):
        return cls(0.0, 0.0, 0.0, 1.0)
    
    @classmethod
    def neg_unit_w(cls):
        return cls(0.0,0.0,0.0,-1.0)
    
    def __cinit__(self, double x, double y, double z, double w):
        self.x = x
        self.y = y
        self.z = z
        self.w = w
        
    def __repr__(self):
        return 'Vector4(%.2f, %.2f, %.2f, %.2f)' % \
            (self.x, self.y, self.z, self.w)
            
    def __len__(self):
        return 4
    
    def __nonzero__(self):
        return sum( self.x, self.y, self.z, self.w ) > 0.0
    
    def __getitem__(self, key):
        return (self.x, self.y, self.z, self.w)[key]
    
    def __setitem__(self, key, value):
        n = [self.x, self.y, self.z, self.w]
        n[key] = value
        self.x, self.y, self.z, self.w = n
        
    cpdef Vector4 copy(self):
        return self.__class__(self.x, self.y, self.z, self.w)
        
    def __iter__(self):
        return iter((self.x, self.y, self.z, self.w))
            
    def __add__(self, Vector4 other):
        return Vector4( self.x + other.x, self.y + other.y, self.z + other.z, self.w + other.w )
    
    def __iadd__(self, Vector4 other):
        self.x += other.x
        self.y += other.y
        self.z += other.z
        self.w += other.w
        return self
    
    __radd__ = __add__
    
    def __sub__(self, Vector4 other):
        cdef Vector4 result
        result = Vector4( self.x - other.x, self.y - other.y, self.z - other.z, self.w - other.w )
        return result
    
    def __isub__(self, Vector4 other):
        self.x -= other.x
        self.y -= other.y
        self.z -= other.z
        self.w -= other.w
        return self
    
    def __rsub__(self, Vector4 other):
        return Vector4(other.x - self.x, other.y - self.y, other.z - self.z, other.w - self.w)
    
    # for speed, these methods are unrolled, we could have it all inside the __mul__
    # overload, but the type check is expensive    
    def __mul__(self, Vector4 other):
        return Vector4(self.x * other.x, self.y * other.y, self.z * other.z, self.w * other.w)
    
    def __imul__(self, Vector4 other):
        self.x *= other.x
        self.y *= other.y
        self.z *= other.z
        self.w *= other.w
        return self
        
#     cpdef Vector3 mulQuaternion(self, Quaternion Q):
#         cdef double w, x, y, z, Vx, Vy, Vz, ww, w2, wx2, wy2, wz2, xx, x2, xy2, xz2, yy, yz2, zz
#         cdef Vector3 result
#         w = Q.w
#         x = Q.x
#         y = Q.y
#         z = Q.z
#         Vx = self.x
#         Vy = self.y
#         Vz = self.z
#         ww = w * w
#         w2 = w * 2
#         wx2 = w2 * x
#         wy2 = w2 * y
#         wz2 = w2 * z
#         xx = x * x
#         x2 = x * 2
#         xy2 = x2 * y
#         xz2 = x2 * z
#         yy = y * y
#         yz2 = 2 * y * z
#         zz = z * z
#         result = Vector3(\
#            ww * Vx + wy2 * Vz - wz2 * Vy + \
#            xx * Vx + xy2 * Vy + xz2 * Vz - \
#            zz * Vx - yy * Vx,
#            xy2 * Vx + yy * Vy + yz2 * Vz + \
#            wz2 * Vx - zz * Vy + ww * Vy - \
#            wx2 * Vz - xx * Vy,
#            xz2 * Vx + yz2 * Vy + \
#            zz * Vz - wy2 * Vx - yy * Vz + \
#            wx2 * Vy - xx * Vz + ww * Vz)
#         return result
    
    cpdef Vector4 mulScalar(self, double other):
        return Vector4( self.x * other, self.y * other, self.z * other, self.w * other)
    
    def __div__(self, double other):
        return Vector4( self.x / other, self.y / other, self.z / other, self.w / other)
    
    def __idiv__(self, double other):
        self.x /= other
        self.y /= other
        self.z /= other
        self.w /= other
        return self
    
    cpdef normalize( self ):
        cdef double mag
        mag = self.length()
        if mag:
            self /= mag
        return self
    
    cpdef Vector4 normalizedCopy(self):
        cdef Vector4 result
        cdef double mag
        result = self.copy()
        mag = self.length()
        if mag:
            result /= mag
        return result
    
    cdef inline double length(self):
        return sqrt(self.x**2 + self.y**2 + self.z**2 + self.w**2)
    
    property length:
        def __get__(self):
            return self.length()
        def __set__(self, double value):
            self.normalize().mulScalar(value)
            
    cpdef double distanceTo( self, Vector4 other ):
        cdef Vector4 delta
        delta = other - self
        return delta.length()
            
    cpdef double squaredLength(self):
        return self.x**2+self.y**2+self.z**2+self.w**2
    
    cpdef double dot(self, Vector4 other):
        return self.x*other.x+self.y*other.y+self.z*other.z+self.w*other.w
    
    cpdef Vector4 lerp(self, Vector4 final, double percent):
        return self + ((final-self).mulScalar(percent))
    
    cpdef Vector4 reflect (self, Vector4 normal):
        cdef double d
        cdef Vector4 result
        d = 2 * ( self.x * normal.x + self.x * normal.y + self.z * normal.z + self.w + normal.w )
        result = Vector4(self.x - d * normal.x,
                         self.y - d * normal.y,
                         self.z - d * normal.z,
                         self.w - d * normal.w)
        return result
    
    cpdef double angleTo (self, Vector4 other):
        return acos(self.dot(other) / (self.length()*other.length()))
    
    cpdef Vector4 project( self, Vector4 other ):
        cdef Vector4 n
        n = other.normalizedCopy()
        return self.dot(n)*n
    
#     cpdef Vector4 cross (self, Vector4 other ):
#         cdef Vector3 ret
#         ret = Vector3( self.y * other.z - self.z * other.y,
#                        self.z * other.x - self.x * other.z,
#                        self.x * other.y - self.y * other.x )
#         return ret
    
    