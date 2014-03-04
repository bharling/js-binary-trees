from libc.math cimport sqrt, cos, sin, asin, acos
from Vector3 cimport Vector3

cdef class Quaternion:
    
    def __cinit__(self, double w=1.0, double x=0.0, double y=0.0, double z=0.0):
        self.w = w
        self.x = x
        self.y = y
        self.z = z
        
    def __init__(self, double w=1.0, double x=0.0, double y=0.0, double z=0.0):
        self.w = w
        self.x = x
        self.y = y
        self.z = z
        
    cpdef Quaternion copy(self):
        cdef Quaternion Q
        Q = Quaternion()
        Q.w = self.w
        Q.x = self.x
        Q.y = self.y
        Q.z = self.z
        return Q
    
    def __repr__(self):
        return 'Quaternion(real=%.2f, imag=<%.2f, %.2f, %.2f>)' % \
            (self.w, self.x, self.y, self.z)
            
    def __mul__(self, Quaternion other):
        cdef double Ax, Ay, Az, Aw, Bx, By, Bz, Bw
        cdef Quaternion result
        Ax = self.x
        Ay = self.y
        Az = self.z
        Aw = self.w
        Bx = other.x
        By = other.y
        Bz = other.z
        Bw = other.w
        result = Quaternion()
        result.x =  Ax * Bw + Ay * Bz - Az * By + Aw * Bx    
        result.y = -Ax * Bz + Ay * Bw + Az * Bx + Aw * By
        result.z =  Ax * By - Ay * Bx + Az * Bw + Aw * Bz
        result.w = -Ax * Bx - Ay * By - Az * Bz + Aw * Bw
        return result
    
    def __imul__(self, Quaternion other):
        cdef double Ax, Ay, Az, Aw, Bx, By, Bz, Bw
        Ax = self.x
        Ay = self.y
        Az = self.z
        Aw = self.w
        Bx = other.x
        By = other.y
        Bz = other.z
        Bw = other.w
        self.x =  Ax * Bw + Ay * Bz - Az * By + Aw * Bx    
        self.y = -Ax * Bz + Ay * Bw + Az * Bx + Aw * By
        self.z =  Ax * By - Ay * Bx + Az * Bw + Aw * Bz
        self.w = -Ax * Bx - Ay * By - Az * Bz + Aw * Bw
        return self
    
    cpdef double length(self):
        return sqrt(self.w**2 +
                    self.x**2 +
                    self.y**2 +
                    self.z**2)
    
    cpdef double squaredLength(self):
        return self.w**2+self.x**2+self.y**2+self.z**2
    
    cpdef identity(self):
        self.w = 1.0
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
        return self
    
    cpdef Quaternion conjugated(self):
        cdef Quaternion result
        result = Quaternion()
        result.w = self.w
        result.x = -self.x
        result.y = -self.y
        result.z = -self.z
        return result
    
    cpdef normalize(self):
        cdef double mag = self.length()
        if mag:
            self.w /= mag
            self.x /= mag
            self.y /= mag
            self.z /= mag
        return self
    
    cpdef Quaternion normalizedCopy(self):
        cdef double mag
        cdef Quaternion result
        result = Quaternion()
        mag = self.length()
        if mag:
            result.w = self.w / mag
            result.x = self.x / mag
            result.y = self.y / mag
            result.z = self.z / mag
        return result
    
    @classmethod
    def fromAxisAngle(cls, Vector3 axis, double angle):
        axis = axis.normalizedCopy()
        cdef double s = sin(angle/2.0)
        cdef Quaternion Q
        Q = cls()
        Q.w = cos(angle/2.0)
        Q.x = axis.x * s
        Q.y = axis.y * s
        Q.z = axis.z * s
        return Q
            
            
        