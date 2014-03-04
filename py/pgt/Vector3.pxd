
from Quaternion cimport Quaternion

cdef class Vector3:
    cdef public double x, y, z
    cpdef Vector3 mulQuaternion(self, Quaternion Q)
    cpdef Vector3 mulScalar(self, double other)
    cpdef Vector3 copy(self)
    cpdef normalize( self )
    cpdef normalizedCopy(self)
    cdef inline double length(self)
    cpdef double squaredLength(self)
    cpdef double dot(self, Vector3 other)
    cpdef Vector3 lerp(self, Vector3 final, double percent)
    cpdef Vector3 cross(self, Vector3 other)
    cpdef Vector3 reflect(self, Vector3 normal)
    cpdef double angleTo(self, Vector3 other)
    cpdef Vector3 project(self, Vector3 other)
    cpdef double distanceTo(self, Vector3 other)
    cpdef Vector3 cross(self, Vector3 other )