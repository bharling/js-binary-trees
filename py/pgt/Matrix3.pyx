from libc.math cimport sqrt

cdef class Matrix3:
    cdef double a, b, c, e, f, g, i, j, k
    
    def __init__(self):
        self.identity()
        
    cpdef identity(self):
        self.a = 1.0
        self.b = 0.0
        self.c = 0.0
        self.e = 0.0
        self.f = 1.0
        self.g = 0.0
        self.i = 0.0
        self.j = 0.0
        self.k = 1.0
        
    cpdef Matrix3 copy(self):
        cdef Matrix3 mat
        mat = Matrix3()
        mat.a = self.a
        mat.b = self.b
        mat.c = self.c
        mat.e = self.e
        mat.f = self.f
        mat.g = self.g
        mat.i = self.i
        mat.j = self.j
        mat.k = self.k
        return mat
    
    __copy__ = copy
    
    
    