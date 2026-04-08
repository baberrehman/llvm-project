! Test lowering of OpenMP metadirective with implementation selectors.

! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=50 %s -o - | FileCheck %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=51 %s -o - | FileCheck %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=52 -cpp -DOMP_52 %s -o - | FileCheck %s

! CHECK-LABEL: func.func @_QPtest_vendor_llvm()
! CHECK:         omp.taskwait
! CHECK:         return
subroutine test_vendor_llvm()
  !$omp metadirective &
  !$omp & when(implementation={vendor(llvm)}: taskwait) &
#ifdef OMP_52
  !$omp & otherwise(nothing)
#else
  !$omp & default(nothing)
#endif
end subroutine

! CHECK-LABEL: func.func @_QPtest_vendor_no_match()
! CHECK-NOT:     omp.taskwait
! CHECK:         return
subroutine test_vendor_no_match()
  !$omp metadirective &
  !$omp & when(implementation={vendor("unknown")}: taskwait) &
#ifdef OMP_52
  !$omp & otherwise(nothing)
#else
  !$omp & default(nothing)
#endif
end subroutine

! CHECK-LABEL: func.func @_QPtest_standalone_barrier_match()
! CHECK:         omp.barrier
! CHECK:         return
subroutine test_standalone_barrier_match()
  !$omp metadirective &
  !$omp & when(implementation={vendor(llvm)}: barrier) &
#ifdef OMP_52
  !$omp & otherwise(nothing)
#else
  !$omp & default(nothing)
#endif
end subroutine

! CHECK-LABEL: func.func @_QPtest_standalone_barrier_fallback()
! CHECK:         omp.barrier
! CHECK:         return
subroutine test_standalone_barrier_fallback()
  !$omp metadirective &
  !$omp & when(implementation={vendor("cray")}: nothing) &
#ifdef OMP_52
  !$omp & otherwise(barrier)
#else
  !$omp & default(barrier)
#endif
end subroutine

! CHECK-LABEL: func.func @_QPtest_nothing_variant()
! CHECK-NOT:     omp.taskwait
! CHECK:         return
subroutine test_nothing_variant()
  !$omp metadirective &
  !$omp & when(implementation={vendor(llvm)}: nothing) &
#ifdef OMP_52
  !$omp & otherwise(taskwait)
#else
  !$omp & default(taskwait)
#endif
end subroutine

! CHECK-LABEL: func.func @_QPtest_default_fallback()
! CHECK:         omp.taskwait
! CHECK:         return
subroutine test_default_fallback()
  !$omp metadirective &
  !$omp & when(implementation={vendor("unknown")}: nothing) &
#ifdef OMP_52
  !$omp & otherwise(taskwait)
#else
  !$omp & default(taskwait)
#endif
end subroutine

! CHECK-LABEL: func.func @_QPtest_no_default()
! CHECK-NOT:     omp.taskyield
! CHECK:         return
subroutine test_no_default()
  !$omp metadirective &
  !$omp & when(implementation={vendor("gnu")}: taskyield)
end subroutine

! CHECK-LABEL: func.func @_QPtest_multiple_when_first_match()
! CHECK:         omp.taskwait
! CHECK-NOT:     omp.taskyield
! CHECK:         return
subroutine test_multiple_when_first_match()
  !$omp metadirective &
  !$omp & when(implementation={vendor(llvm)}: taskwait) &
  !$omp & when(user={condition(.false.)}: taskyield) &
#ifdef OMP_52
  !$omp & otherwise(nothing)
#else
  !$omp & default(nothing)
#endif
end subroutine

! CHECK-LABEL: func.func @_QPtest_multiple_when_fallback()
! CHECK-NOT:     omp.taskyield
! CHECK:         omp.taskwait
! CHECK:         return
subroutine test_multiple_when_fallback()
  !$omp metadirective &
  !$omp & when(implementation={vendor("nvidia")}: taskyield) &
  !$omp & when(user={condition(.false.)}: taskyield) &
#ifdef OMP_52
  !$omp & otherwise(taskwait)
#else
  !$omp & default(taskwait)
#endif
end subroutine

! Below is ported from clang/test/OpenMP/metadirective_implementation_codegen.c

! CHECK-LABEL: func.func @_QPtest_implementation_vendor_score_device_cpu()
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
subroutine test_implementation_vendor_score_device_cpu()
  integer :: i
  !$omp metadirective &
  !$omp & when(implementation={vendor(score(0): llvm)}, device={kind(cpu)}: parallel do) &
#ifdef OMP_52
  !$omp & otherwise(target teams distribute parallel do)
#else
  !$omp & default(target teams distribute parallel do)
#endif
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_implementation_second_when_matches()
! CHECK-NOT:     omp.target
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
subroutine test_implementation_second_when_matches()
  integer :: i
  !$omp metadirective &
  !$omp & when(device={kind(gpu)}: target teams distribute parallel do) &
  !$omp & when(implementation={vendor(llvm)}: parallel do) &
#ifdef OMP_52
  !$omp & otherwise(nothing)
#else
  !$omp & default(nothing)
#endif
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_implementation_default_before_when()
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
subroutine test_implementation_default_before_when()
  integer :: i
  !$omp metadirective &
#ifdef OMP_52
  !$omp & otherwise(do) &
#else
  !$omp & default(do) &
#endif
  !$omp & when(implementation={vendor(score(5): llvm)}, device={kind(cpu, host)}: parallel do)
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_implementation_extension_match_all()
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
! CHECK-NOT:     omp.simd
subroutine test_implementation_extension_match_all()
  integer :: i
  !$omp metadirective &
  !$omp & when(implementation={extension(match_all)}: parallel do) &
#ifdef OMP_52
  !$omp & otherwise(do simd)
#else
  !$omp & default(do simd)
#endif
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_implementation_extension_match_any()
! CHECK-NOT:     omp.parallel
! CHECK:         omp.wsloop
! CHECK:           omp.simd
subroutine test_implementation_extension_match_any()
  integer :: i
  !$omp metadirective &
  !$omp & when(implementation={extension(match_any)}: parallel do) &
#ifdef OMP_52
  !$omp & otherwise(do simd)
#else
  !$omp & default(do simd)
#endif
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_implementation_extension_match_none()
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
! CHECK-NOT:     omp.simd
subroutine test_implementation_extension_match_none()
  integer :: i
  !$omp metadirective &
  !$omp & when(implementation={extension(match_none)}: parallel do) &
#ifdef OMP_52
  !$omp & otherwise(do simd)
#else
  !$omp & default(do simd)
#endif
  do i = 1, 100
  end do
end subroutine