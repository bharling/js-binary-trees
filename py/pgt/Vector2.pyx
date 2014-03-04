import random

from libc.math cimport sqrt

cdef class Vector2:
    cdef double x
    cdef double y
    
    @classmethod
    def random(cls):
        return cls(random.uniform(-1.0, 1.0), random.uniform(-1.0, 1.0))
    
    def __cinit__(self, double x, double y):
        self.x = x
        self.y = y
        
    def __init__(self, x, y):
        self.x = x
        self.y = y
        
    property x:
        def __get__(self):
            return self.x
        def __set__(self, value):
            self.x = value
            
    property y:
        def __get__(self):
            return self.y
        def __set__(self, value):
            self.y = value
    
    def __add__(self, Vector2 other):
        return Vector2(self.x+other.x, self.y+other.y)
    
    def __iadd__(self, Vector2 other):
        self.x+=other.x
        self.y+=other.y
        return self
        
    def __sub__(self, Vector2 other):
        return Vector2(self.x-other.x, self.y-other.y)
    
    def __isub__(self, Vector2 other):
        self.x-=other.x
        self.y-=other.y
        return self
        
    def __mul__(self, Vector2 other):
        return Vector2(self.x*other.x, self.y*other.y)
    
    cpdef Vector2 mulScalar(self, double other):
        return Vector2(self.x*other, self.y*other)

    def __imul__(self, other):
        if hasattr(other, 'x'):
            self.x*=other.x
            self.y*=other.y
        else:
            self.x *= float(other)
            self.y *= float(other)
        return self
            
    def __div__(self, other):
        if hasattr(other, 'x'):
            return Vector2(self.x/other.x, self.y/other.y)
        else:
            return Vector2(self.x/float(other), self.y/float(other))
        
    def __idiv__(self, other):
        if hasattr(other, 'x'):
            self.x/=other.x
            self.y/=other.y
        else:
            self.x /= float(other)
            self.y /= float(other)
        return self
            
    cdef double length(self):
        return sqrt(self.x**2+self.y**2)
    
    property length:
        def __get__(self):
            return self.length()
        def __set__(self, double other):
            self.normalize()
            self.mulScalar(other)
    
    cpdef double squaredLength(self):
        return self.x**2+self.y**2
        
    cpdef Vector2 copy(self):
        return Vector2(self.x, self.y)
        
    cpdef Vector2 normalizedCopy(self):
        return self.copy() / self.length()
    
    cpdef Vector2 normalize(self):
        self /= self.length()
        return self
        
    cpdef double dot(self, Vector2 other):
        return self.x*other.x+self.y*other.y
        
    cpdef Vector2 lerp(self,Vector2 final, double percent):
        return self + ((final-self).mulScalar(percent))