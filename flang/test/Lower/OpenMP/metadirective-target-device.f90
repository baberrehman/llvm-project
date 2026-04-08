! REQUIRES: amdgpu-registered-target

! Test metadirective with target_device trait selectors.

! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=52 %s -o - | FileCheck --check-prefix=HOST %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=52 -triple amdgcn-amd-amdhsa -fopenmp-is-target-device %s -o - | FileCheck --check-prefix=AMDGCN %s

! HOST-LABEL: func.func @_QPtest_target_device_kind_gpu()
! HOST-NOT:     omp.target
! HOST:         omp.parallel
! HOST-NOT:     omp.distribute
! HOST:         omp.wsloop
! AMDGCN-LABEL: func.func @_QPtest_target_device_kind_gpu()
! AMDGCN-NOT:     omp.taskwait
! AMDGCN:         omp.target
! AMDGCN:         omp.teams
! AMDGCN:         omp.parallel
! AMDGCN:         omp.distribute
! AMDGCN:         omp.wsloop
subroutine test_target_device_kind_gpu(a, n)
  real, intent(inout) :: a(:)
  integer, intent(in) :: n
  !$omp metadirective &
  !$omp & when(target_device={kind(gpu)}: target teams distribute parallel do) &
  !$omp & otherwise(parallel do)
  do i = 1, n
    a(i) = a(i) + 1.0
  end do
end subroutine

! HOST-LABEL: func.func @_QPtest_target_device_arch_amdgcn()
! HOST-NOT:     omp.target
! HOST-NOT:     omp.parallel
! HOST:         omp.taskwait
! HOST:         fir.do_loop
! AMDGCN-LABEL: func.func @_QPtest_target_device_arch_amdgcn()
! AMDGCN-NOT:     omp.taskwait
! AMDGCN:         omp.target
! AMDGCN:         omp.teams
! AMDGCN:         omp.parallel
! AMDGCN:         omp.distribute
! AMDGCN:         omp.wsloop
subroutine test_target_device_arch_amdgcn(a, n)
  real, intent(inout) :: a(:)
  integer, intent(in) :: n
  !$omp metadirective &
  !$omp & when(target_device={arch(amdgcn)}: target teams distribute parallel do) &
  !$omp & otherwise(taskwait)
  do i = 1, n
    a(i) = a(i) * 2.0
  end do
end subroutine