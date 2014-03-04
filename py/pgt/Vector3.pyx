import random
from libc.math cimport sqrt, acos
from Quaternion cimport Quaternion

# portions of this code adapted from
# https://code.google.com/p/pyeuclid


cdef class Vector3:
    
    @classmethod
    def random(cls):
        return cls(random.uniform(-1.0, 1.0), random.uniform(-1.0, 1.0), random.uniform(-1.0, 1.0))
    
    @classmethod
    def zero(cls):
        return cls(0.0, 0.0, 0.0)
    
    @classmethod
    def ones(cls):
        return cls(1.0, 1.0, 1.0)
    
    @classmethod
    def unit_z(cls):
        return cls(0.0, 0.0, 1.0)
    
    @classmethod
    def unit_x(cls):
        return cls(1.0, 0.0, 0.0)
    
    @classmethod
    def unit_y(cls):
        return cls(0.0, 1.0, 0.0)
    
    @classmethod
    def neg_unit_x(cls):
        return cls(-1.0, 0.0, 0.0)
    
    @classmethod
    def neg_unit_y(cls):
        return cls(0.0, -1.0, 0.0)
    
    @classmethod
    def neg_unit_z(cls):
        return cls(0.0, 0.0, -1.0)
    
    def __cinit__(self, double x, double y, double z):
        self.x = x
        self.y = y
        self.z = z
        
    def __repr__(self):
        return 'Vector3(%.2f, %.2f, %.2f)' % \
            (self.x, self.y, self.z)
            
    def __len__(self):
        return 3
    
    def __nonzero__(self):
        if self.x != 0.0 or self.y != 0.0 or self.z != 0.0 : 
            return 1
        return 0
    
    def __getitem__(self, key):
        return (self.x, self.y, self.z)[key]
    
    def __setitem__(self, key, value):
        n = [self.x, self.y, self.z]
        n[key] = value
        self.x, self.y, self.z = n
        
    cpdef Vector3 copy(self):
        return self.__class__(self.x, self.y, self.z)
        
    def __iter__(self):
        return iter((self.x, self.y, self.z))
            
    def __add__(self, Vector3 other):
        return Vector3( self.x + other.x, self.y + other.y, self.z + other.z )
    
    def __iadd__(self, Vector3 other):
        self.x += other.x
        self.y += other.y
        self.z += other.z
        return self
    
    __radd__ = __add__
    
    def __sub__(self, Vector3 other):
        cdef Vector3 result
        result = Vector3( self.x - other.x, self.y - other.y, self.z - other.z )
        return result
    
    def __isub__(self, Vector3 other):
        self.x -= other.x
        self.y -= other.y
        self.z -= other.z
        return self
    
    def __rsub__(self, other):
        return Vector3(other.x - self.x, other.y - self.y, other.z - self.z)
    
    # for speed, these methods are unrolled, we could have it all inside the __mul__
    # overload, but the type check is expensive    
    def __mul__(self, Vector3 other):
        return Vector3(self.x * other.x, self.y * other.y, self.z * other.z)
    
    def __imul__(self, Vector3 other):
        self.x *= other.x
        self.y *= other.y
        self.z *= other.z
        return self
        
    cpdef Vector3 mulQuaternion(self, Quaternion Q):
        cdef double w, x, y, z, Vx, Vy, Vz, ww, w2, wx2, wy2, wz2, xx, x2, xy2, xz2, yy, yz2, zz
        cdef Vector3 result
        w = Q.w
        x = Q.x
        y = Q.y
        z = Q.z
        Vx = self.x
        Vy = self.y
        Vz = self.z
        ww = w * w
        w2 = w * 2
        wx2 = w2 * x
        wy2 = w2 * y
        wz2 = w2 * z
        xx = x * x
        x2 = x * 2
        xy2 = x2 * y
        xz2 = x2 * z
        yy = y * y
        yz2 = 2 * y * z
        zz = z * z
        result = Vector3(\
           ww * Vx + wy2 * Vz - wz2 * Vy + \
           xx * Vx + xy2 * Vy + xz2 * Vz - \
           zz * Vx - yy * Vx,
           xy2 * Vx + yy * Vy + yz2 * Vz + \
           wz2 * Vx - zz * Vy + ww * Vy - \
           wx2 * Vz - xx * Vy,
           xz2 * Vx + yz2 * Vy + \
           zz * Vz - wy2 * Vx - yy * Vz + \
           wx2 * Vy - xx * Vz + ww * Vz)
        return result
    
    cpdef Vector3 mulScalar(self, double other):
        return Vector3( self.x * other, self.y * other, self.z * other)
    
    def __div__(self, double other):
        return Vector3( self.x / other, self.y / other, self.z / other)
    
    def __idiv__(self, double other):
        self.x /= other
        self.y /= other
        self.z /= other
        return self
    
    cpdef normalize( self ):
        cdef double mag
        mag = self.length()
        if mag:
            self /= mag
        return self
    
    cpdef normalizedCopy(self):
        cdef Vector3 result
        cdef double mag
        result = self.copy()
        mag = self.length()
        if mag:
            result /= mag
        return result
    
    cdef inline double length(self):
        return sqrt(self.x**2 + self.y**2 + self.z**2)
    
    property length:
        def __get__(self):
            return self.length()
        def __set__(self, double value):
            self.normalize().mulScalar(value)
            
    cpdef double distanceTo( self, Vector3 other ):
        cdef Vector3 delta
        delta = other - self
        return delta.length()
            
    cpdef double squaredLength(self):
        return self.x**2+self.y**2+self.z**2
    
    cpdef double dot(self, Vector3 other):
        return self.x*other.x+self.y*other.y+self.z*other.z
    
    cpdef Vector3 lerp(self, Vector3 final, double percent):
        return self + ((final-self).mulScalar(percent))
    
    cpdef Vector3 reflect (self, Vector3 normal):
        cdef double d
        cdef Vector3 result
        d = 2 * ( self.x * normal.x + self.x * normal.y + self.z * normal.z )
        result = Vector3(self.x - d * normal.x,
                         self.y - d * normal.y,
                         self.z - d * normal.z)
        return result
    
    cpdef double angleTo (self, Vector3 other):
        return acos(self.dot(other) / (self.length()*other.length()))
    
    cpdef Vector3 project( self, Vector3 other ):
        cdef Vector3 n
        n = other.normalizedCopy()
        return self.dot(n)*n
    
    cpdef Vector3 cross (self, Vector3 other ):
        cdef Vector3 ret
        ret = Vector3( self.y * other.z - self.z * other.y,
                       self.z * other.x - self.x * other.z,
                       self.x * other.y - self.y * other.x )
        return ret
    
    