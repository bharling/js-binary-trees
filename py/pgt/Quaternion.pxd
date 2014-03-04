cdef class Quaternion:
	cdef public double w, x, y, z
	cpdef Quaternion copy( self )
	cpdef double length(self)
	cpdef double squaredLength(self)
	cpdef identity(self)
	cpdef Quaternion conjugated(self)
	cpdef normalize(self)
	cpdef Quaternion normalizedCopy(self)
	