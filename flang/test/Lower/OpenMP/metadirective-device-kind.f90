! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=50 %s -o - | FileCheck %s

! CHECK-LABEL: func.func @_QPtest_device_kind_host()
! CHECK:         omp.taskyield
! CHECK:         return
subroutine test_device_kind_host()
  !$omp metadirective &
  !$omp & when(device={kind(host)}: taskyield) &
  !$omp & default(nothing)
end subroutine

! CHECK-LABEL: func.func @_QPtest_multiple_when_second_match()
! CHECK-NOT:     omp.taskwait
! CHECK:         omp.taskyield
! CHECK:         return
subroutine test_multiple_when_second_match()
  !$omp metadirective &
  !$omp & when(implementation={vendor("amd")}: taskwait) &
  !$omp & when(device={kind(host)}: taskyield) &
  !$omp & default(nothing)
end subroutine

! CHECK-LABEL: func.func @_QPtest_device_kind_any_parallel_do()
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
subroutine test_device_kind_any_parallel_do()
  integer :: i
  !$omp metadirective &
  !$omp & when(device={kind(any)}: parallel do) &
  !$omp & default(do)
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_device_kind_host_cpu_parallel_do_num_threads()
! CHECK:         omp.parallel num_threads(
! CHECK:           omp.wsloop
subroutine test_device_kind_host_cpu_parallel_do_num_threads()
  integer :: i
  !$omp metadirective &
  !$omp & when(device={kind(host, cpu)}: parallel do num_threads(4)) &
  !$omp & default(do)
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_device_kind_host_parallel_do()
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
subroutine test_device_kind_host_parallel_do()
  integer :: i
  !$omp metadirective &
  !$omp & when(device={kind(host)}: parallel do) &
  !$omp & default(do)
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_device_kind_cpu_second_match()
! CHECK-NOT:     omp.target
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
subroutine test_device_kind_cpu_second_match()
  integer :: i
  !$omp metadirective &
  !$omp & when(device={kind(nohost, gpu)}: nothing) &
  !$omp & when(device={kind(cpu)}: parallel do) &
  !$omp & default(do)
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_device_kind_any_cpu_parallel_do()
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
subroutine test_device_kind_any_cpu_parallel_do()
  integer :: i
  !$omp metadirective &
  !$omp & when(device={kind(any, cpu)}: parallel do) &
  !$omp & default(do)
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_device_kind_any_host_parallel_do()
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
subroutine test_device_kind_any_host_parallel_do()
  integer :: i
  !$omp metadirective &
  !$omp & when(device={kind(any, host)}: parallel do) &
  !$omp & default(do)
  do i = 1, 100
  end do
end subroutine

! CHECK-LABEL: func.func @_QPtest_device_kind_gpu_fallback_parallel_do()
! CHECK-NOT:     omp.target
! CHECK:         omp.parallel
! CHECK:           omp.wsloop
subroutine test_device_kind_gpu_fallback_parallel_do()
  integer :: i
  !$omp metadirective &
  !$omp & when(device={kind(gpu)}: target parallel do) &
  !$omp & default(parallel do)
  do i = 1, 100
  end do
end subroutine
