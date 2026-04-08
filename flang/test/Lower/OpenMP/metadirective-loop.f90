! Test lowering of metadirective with loop-associated directive variants.

! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=50 %s -o - | FileCheck %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=51 %s -o - | FileCheck %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=52 -cpp -DOMP_52 %s -o - | FileCheck %s

! CHECK-LABEL: func @_QPtest_loop_vendor_match
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
! CHECK:             omp.loop_nest
! CHECK-NOT:    fir.if
subroutine test_loop_vendor_match(a, n)
  real, intent(inout) :: a(:)
  integer, intent(in) :: n
  !$omp metadirective &
  !$omp   when(implementation={vendor(llvm)}: parallel do) &
#ifdef OMP_52
  !$omp   otherwise(do)
#else
  !$omp   default(do)
#endif
  do i = 1, n
    a(i) = a(i) + 1.0
  end do
end subroutine

! Vendor does not match, fallback to default(do).
! CHECK-LABEL: func @_QPtest_loop_vendor_no_match
! CHECK-NOT:     omp.parallel
! CHECK:         omp.wsloop
! CHECK:           omp.loop_nest
subroutine test_loop_vendor_no_match(b, n)
  real, intent(inout) :: b(:)
  integer, intent(in) :: n
  !$omp metadirective &
  !$omp   when(implementation={vendor("unknown")}: parallel do) &
#ifdef OMP_52
  !$omp   otherwise(do)
#else
  !$omp   default(do)
#endif
  do i = 1, n
    b(i) = b(i) * 2.0
  end do
end subroutine

! Vendor does not match, fallback to parallel do.
! CHECK-LABEL: func @_QPtest_loop_parallel_do_fallback
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
! CHECK:             omp.loop_nest
! CHECK-NOT:    omp.simd
subroutine test_loop_parallel_do_fallback(c, n)
  real, intent(inout) :: c(:)
  integer, intent(in) :: n
  !$omp metadirective &
  !$omp   when(implementation={vendor("unknown")}: do) &
#ifdef OMP_52
  !$omp   otherwise(parallel do)
#else
  !$omp   default(parallel do)
#endif
  do i = 1, n
    c(i) = c(i) - 1.0
  end do
end subroutine

! Vendor matches, select simd directly.
! CHECK-LABEL: func @_QPtest_loop_simd_match
! CHECK-NOT:     omp.parallel
! CHECK-NOT:     omp.wsloop
! CHECK:         omp.simd
! CHECK:           omp.loop_nest
subroutine test_loop_simd_match(d, n)
  real, intent(inout) :: d(:)
  integer, intent(in) :: n
  !$omp metadirective &
  !$omp   when(implementation={vendor(llvm)}: simd) &
#ifdef OMP_52
  !$omp   otherwise(do)
#else
  !$omp   default(do)
#endif
  do i = 1, n
    d(i) = d(i) + 3.0
  end do
end subroutine

! Vendor does not match, fallback to simd.
! CHECK-LABEL: func @_QPtest_loop_simd_fallback
! CHECK-NOT:     omp.parallel
! CHECK-NOT:     omp.wsloop
! CHECK:         omp.simd
! CHECK:           omp.loop_nest
subroutine test_loop_simd_fallback(g, n)
  real, intent(inout) :: g(:)
  integer, intent(in) :: n
  !$omp metadirective &
  !$omp   when(implementation={vendor("gnu")}: do) &
#ifdef OMP_52
  !$omp   otherwise(simd)
#else
  !$omp   default(simd)
#endif
  do i = 1, n
    g(i) = g(i) + 5.0
  end do
end subroutine

! Vendor does not match, fallback to default(do simd).
! CHECK-LABEL: func @_QPtest_loop_do_simd_fallback
! CHECK-NOT:     omp.parallel
! CHECK:         omp.wsloop
! CHECK:           omp.simd
! CHECK:             omp.loop_nest
subroutine test_loop_do_simd_fallback(e, n)
  real, intent(inout) :: e(:)
  integer, intent(in) :: n
  !$omp metadirective &
  !$omp   when(implementation={vendor("nvidia")}: parallel do) &
#ifdef OMP_52
  !$omp   otherwise(do simd)
#else
  !$omp   default(do simd)
#endif
  do i = 1, n
    e(i) = e(i) - 2.0
  end do
end subroutine

! Vendor matches, select the composite parallel do simd.
! CHECK-LABEL: func @_QPtest_loop_parallel_do_simd_match
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
! CHECK:             omp.simd
! CHECK:               omp.loop_nest
subroutine test_loop_parallel_do_simd_match(f, n)
  real, intent(inout) :: f(:)
  integer, intent(in) :: n
  !$omp metadirective &
  !$omp   when(implementation={vendor(llvm)}: parallel do simd) &
#ifdef OMP_52
  !$omp   otherwise(do)
#else
  !$omp   default(do)
#endif
  do i = 1, n
    f(i) = f(i) * 4.0
  end do
end subroutine

! No match and no default, implicit nothing; loop is plain sequential.
! CHECK-LABEL: func @_QPtest_loop_no_default
! CHECK-NOT:     omp.parallel
! CHECK-NOT:     omp.wsloop
! CHECK:         fir.do_loop
subroutine test_loop_no_default(h, n)
  real, intent(inout) :: h(:)
  integer, intent(in) :: n
  !$omp metadirective &
  !$omp   when(implementation={vendor("unknown")}: parallel do)
  do i = 1, n
    h(i) = h(i) - 1.0
  end do
end subroutine
