
from Quaternion cimport Quaternion

cdef class Vector4:
    cdef public double x, y, z, w
    cpdef Vector4 mulScalar(self, double other)
    cpdef Vector4 copy(self)
    cpdef normalize( self )
    cpdef Vector4 normalizedCopy(self)
    cdef inline double length(self)
    cpdef double squaredLength(self)
    cpdef double dot(self, Vector4 other)
    cpdef Vector4 lerp(self, Vector4 final, double percent)
    cpdef Vector4 reflect(self, Vector4 normal)
    cpdef double angleTo(self, Vector4 other)
    cpdef Vector4 project(self, Vector4 other)
    cpdef double distanceTo(self, Vector4 other)