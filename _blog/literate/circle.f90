
MODULE Circle
      implicit None
      public :: area
contains
      function area(r) 
      implicit none
      real, intent(in) :: r
      real :: area
      area = 3.14159 * r**2
      return
      end function area
END MODULE Circle
