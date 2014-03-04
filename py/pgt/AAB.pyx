from Vector3 cimport Vector3
from libc.math cimport abs, sqrt, fabs

cdef class AAB:
    
    def __cinit__(self, Vector3 center, Vector3 extents):
        self.center = center
        self.extents = extents
        self.updateBounds()
        
    cdef updateBounds(self):
        cdef double xmin, xmax, ymin, ymax, zmin, zmax
        cdef double halfX, halfY, halfZ
        halfX = self.extents.x / 2.0
        halfY = self.extents.y / 2.0
        halfZ = self.extents.z / 2.0
        
        xmin = self.center.x - halfX
        xmax = self.center.x + halfX
        
        ymin = self.center.y - halfY
        ymax = self.center.y + halfY
        
        zmin = self.center.z - halfZ
        zmax = self.center.z + halfZ
        
        self.minCorner = Vector3(xmin, ymin, zmin)
        self.maxCorner = Vector3(xmax, ymax, xmax)
        
    property height:
        def __get__(self):
            return abs(self.maxCorner.z - self.minCorner.z)
        def __set__(self, double value):
            self.extents.z = value
            self.updateBounds()
            
    property width:
        def __get__(self):
            return abs(self.maxCorner.x - self.minCorner.x)
        def __set__(self, double value):
            self.extents.x = value
            self.updateBounds()
            
    property depth:
        def __get__(self):
            return abs(self.maxCorner.y - self.minCorner.y)
        def __set__(self, double value):
            self.extents.y = value
            self.updateBounds()
            
    cdef updateCenter(self):
        self.center = self.minCorner.lerp(self.maxCorner, 0.5)
            
    cpdef extend (self, Vector3 point):
        """
        aab.extend(point)
        Extend this box so that it completely contains point
        @param point: a Vector3 position to emcompass 
        """
        cdef double x, y, z, minX, minY, minZ, maxX, maxY, maxZ
        x, y, z = point
        minX, minY, minZ = self.minCorner
        maxX, maxY, maxZ = self.maxCorner
        self.minCorner.x = min(minX, x)
        self.maxCorner.x = max(maxX, x)
        self.minCorner.y = min(minY, y)
        self.maxCorner.y = max(maxY, y)
        self.minCorner.z = min(minZ, z)
        self.maxCorner.z = max(maxZ, z)
        self.updateCenter()
        
    cpdef int contains( self, Vector3 point ):
        """
        aab.contains(point)
        return 1 if the point is inside this box
        @param point: Vector3 to test
        """
        if point.x >= self.minCorner.x and \
            point.y >= self.minCorner.y and \
            point.z >= self.minCorner.z and \
            point.x <= self.maxCorner.x and \
            point.y <= self.maxCorner.y and \
            point.z <= self.maxCorner.z: return 1
        return 0
    
    cpdef setCenter( self, Vector3 newCenter ):
        """
        aab.setCenter(newCenter)
        Update the center point of this box and recalculate its bounds
        """
        self.center = newCenter
        self.updateBounds()
        
    cpdef double minVal( self, int i ):
        return self.minCorner[i]
    
    cpdef double maxVal( self, int i ):
        return self.maxCorner[i]
        
        
    cpdef int sweepCollision( self, Vector3 myPreviousPosition, AAB other, Vector3 otherPreviousPosition ):
        """
        conduct a swept collision test for this AAB
        """
        cdef Vector3 Ea, A0, A1, Eb, B0, B1, va, vb, v, u_0, u_1
        cdef AAB A, B
        cdef double u0, u1
        cdef int i
        
        A = AAB( myPreviousPosition, self.extents )
        B = AAB( otherPreviousPosition, other.extents )
        va = self.center - myPreviousPosition
        vb = other.center - otherPreviousPosition
        v = vb - va
        u_0 = Vector3.zero()
        u_1 = Vector3.ones()
        
        cdef double a_min_i, a_max_i, b_min_i, b_max_i, v_i
        
        if A.overlaps(B):
            return 1
        
        for i in range(3):
            
            a_max_i = A.maxVal(i)
            a_min_i = A.minVal(i)
            b_max_i = B.maxVal(i)
            b_min_i = B.minVal(i)
            v_i = v[i]
            
            if a_max_i < b_min_i and v_i < 0.0:
                u_0[i] = (a_max_i - b_min_i) / v_i
            elif b_max_i < a_min_i and v_i > 0.0:
                u_0[i] = (a_min_i - b_max_i) / v_i
                
            if b_max_i > a_min_i and v_i < 0.0:
                u_1[i] = (a_min_i - b_max_i) / v_i
            elif a_max_i > b_min_i and v_i > 0.0:
                u_1[i] = (a_max_i - b_min_i) / v_i
        
        u0 = max( u_0.x, max(u_0.y, u_0.z) )
        u1 = min( u_1.x, min(u_1.y, u_1.z) )
        if u0 <= u1:
            return 1
        return 0
            

    cpdef int overlaps( self, AAB other ):
        """
        aab.overlaps(other)
        Test if this box overlaps another
        @param other: another AAB to test against
        """
        cdef Vector3 offset
        cdef double tX, tY, tZ
        tX = (self.extents.x + other.extents.x) / 2.0
        tY = (self.extents.y + other.extents.y) / 2.0
        tZ = (self.extents.z + other.extents.z) / 2.0
        offset = other.center - self.center
        if fabs(offset.x) <= tX and fabs(offset.y) <= tY and fabs(offset.z) <= tZ:
            return 1
        return 0
    
    
    cdef inline Vector3 GetIntersection( self, double fDst1, double fDst2, Vector3 P1, Vector3 P2):
        cdef Vector3 result
        result = Vector3.zero()
        if fDst1 * fDst2 >= 0.0:
            return result
        
        if fDst1 == fDst2:
            return result
        
        result = P1 + (P2-P1) * (-fDst1/(fDst2-fDst1))
        return result
    
    cdef inline int InBox( self, Vector3 Hit, Vector3 B1, Vector3 B2, int Axis):
        if ( Axis==1 and Hit.z > B1.z and Hit.z < B2.z and Hit.y > B1.y and Hit.y < B2.y ):
            return 1
        if ( Axis==2 and Hit.z > B1.z and Hit.z < B2.z and Hit.x > B1.x and Hit.x < B2.x ):
            return 1
        if ( Axis==3 and Hit.x > B1.x and Hit.x < B2.x and Hit.y > B1.y and Hit.y < B2.y ):
            return 1
        return 0
    
    cpdef Vector3 intersectLine(self, Vector3 L1, Vector3 L2):
        cdef Vector3 Hit, B1, B2
        Hit = Vector3.zero()
        B1 = self.minCorner
        B2 = self.maxCorner
        if (L2.x < B1.x and L1.x < B1.x): return Hit
        if (L2.x > B2.x and L1.x > B2.x): return Hit
        if (L2.y < B1.y and L1.y < B1.y): return Hit
        if (L2.y > B2.y and L1.y > B2.y): return Hit
        if (L2.z < B1.z and L1.z < B1.z): return Hit
        if (L2.z > B2.z and L1.z > B2.z): return Hit
        if (L1.x > B1.x and L1.x < B2.x and L1.y > B1.y and L1.y < B2.y and L1.z > B1.z and L1.z < B2.z):
            Hit = L1
            return Hit
        return Hit
        
#         if ( (GetIntersection( L1.x-B1.x, L2.x-B1.x, L1, L2, Hit) && InBox( Hit, B1, B2, 1 ))
#           || (GetIntersection( L1.y-B1.y, L2.y-B1.y, L1, L2, Hit) && InBox( Hit, B1, B2, 2 )) 
#           || (GetIntersection( L1.z-B1.z, L2.z-B1.z, L1, L2, Hit) && InBox( Hit, B1, B2, 3 )) 
#           || (GetIntersection( L1.x-B2.x, L2.x-B2.x, L1, L2, Hit) && InBox( Hit, B1, B2, 1 )) 
#           || (GetIntersection( L1.y-B2.y, L2.y-B2.y, L1, L2, Hit) && InBox( Hit, B1, B2, 2 )) 
#           || (GetIntersection( L1.z-B2.z, L2.z-B2.z, L1, L2, Hit) && InBox( Hit, B1, B2, 3 )))
#             return true;
#         
#         return false;
    
    
    cpdef AAB intersect( self, AAB other ):
        pass
        