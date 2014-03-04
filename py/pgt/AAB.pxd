from Vector3 cimport Vector3

cdef class AAB:
	cdef public Vector3 center, extents
	cdef Vector3 minCorner, maxCorner
	cpdef extend (self, Vector3 point)
	cpdef int contains( self, Vector3 point )
	cpdef setCenter( self, Vector3 newCenter )
	cpdef AAB intersect( self, AAB other )
	cpdef int overlaps(self, AAB other )
	cdef updateBounds(self)
	cdef updateCenter(self)
	cpdef int sweepCollision(self, Vector3 myPreviousPosition, AAB other, Vector3 otherPreviousPosition )
	cpdef double maxVal ( self, int i )
	cpdef double minVal ( self, int i )
	cdef inline Vector3 GetIntersection( self, double fDst1, double fDst2, Vector3 P1, Vector3 P2)
	cdef inline int InBox( self, Vector3 Hit, Vector3 B1, Vector3 B2, int Axis)
	cpdef Vector3 intersectLine(self, Vector3 L1, Vector3 L2)
        