
program main
      
use circle, only: area

implicit none
integer :: i
REAL, DIMENSION(5) :: R
R = (/1.0, 2.0, 3.0, 4.0, 5.0 /)

print *, "#+tblname: circle-area"
do i = 1, 5
  print *, "|", R(i), "|", area(R(i)), "|"
end do

end program main
