! Test metadirective with device={isa(...)} trait selectors.

! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=50 -target-feature +neon %s -o - | FileCheck --check-prefix=NEON %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=50 -target-feature +neon -target-feature +sve %s -o - | FileCheck --check-prefix=SVE %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=50 -target-feature +sse %s -o - | FileCheck --check-prefix=SSE %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=50 -target-feature +avx %s -o - | FileCheck --check-prefix=AVX %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=50 %s -o - | FileCheck --check-prefix=NONE %s

! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=51 -target-feature +neon %s -o - | FileCheck --check-prefix=NEON %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=51 -target-feature +neon -target-feature +sve %s -o - | FileCheck --check-prefix=SVE %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=51 -target-feature +sse %s -o - | FileCheck --check-prefix=SSE %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=51 -target-feature +avx %s -o - | FileCheck --check-prefix=AVX %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=51 %s -o - | FileCheck --check-prefix=NONE %s

! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=52 -cpp -DOMP_52 -target-feature +neon %s -o - | FileCheck --check-prefix=NEON %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=52 -cpp -DOMP_52 -target-feature +neon -target-feature +sve %s -o - | FileCheck --check-prefix=SVE %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=52 -cpp -DOMP_52 -target-feature +sse %s -o - | FileCheck --check-prefix=SSE %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=52 -cpp -DOMP_52 -target-feature +avx %s -o - | FileCheck --check-prefix=AVX %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=52 -cpp -DOMP_52 %s -o - | FileCheck --check-prefix=NONE %s
! RUN: %if amdgpu-registered-target %{ %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=50 -triple amdgcn-amd-amdhsa -target-cpu gfx906 -fopenmp-is-target-device %s -o - | FileCheck --check-prefix=AMDGCN %s %}

! NEON-LABEL: func.func @_QPtest_isa_neon()
! NEON:         omp.barrier
! SVE-LABEL: func.func @_QPtest_isa_neon()
! SVE:         omp.barrier
! SSE-LABEL: func.func @_QPtest_isa_neon()
! SSE-NOT:     omp.barrier
! SSE:         return
! AVX-LABEL: func.func @_QPtest_isa_neon()
! AVX-NOT:     omp.barrier
! AVX:         return
! NONE-LABEL: func.func @_QPtest_isa_neon()
! NONE-NOT:     omp.barrier
! NONE:         return
subroutine test_isa_neon()
  !$omp metadirective &
  !$omp & when(device={isa("neon")}: barrier) &
#ifdef OMP_52
  !$omp & otherwise(nothing)
#else
  !$omp & default(nothing)
#endif
end subroutine

! NEON-LABEL: func.func @_QPtest_isa_sve()
! NEON-NOT:     omp.barrier
! NEON:         return
! SVE-LABEL: func.func @_QPtest_isa_sve()
! SVE:         omp.barrier
! SSE-LABEL: func.func @_QPtest_isa_sve()
! SSE-NOT:     omp.barrier
! SSE:         return
! AVX-LABEL: func.func @_QPtest_isa_sve()
! AVX-NOT:     omp.barrier
! AVX:         return
! NONE-LABEL: func.func @_QPtest_isa_sve()
! NONE-NOT:     omp.barrier
! NONE:         return
subroutine test_isa_sve()
  !$omp metadirective &
  !$omp & when(device={isa("sve")}: barrier) &
#ifdef OMP_52
  !$omp & otherwise(nothing)
#else
  !$omp & default(nothing)
#endif
end subroutine

! NEON-LABEL: func.func @_QPtest_isa_sse()
! NEON-NOT:     omp.barrier
! NEON:         return
! SVE-LABEL: func.func @_QPtest_isa_sse()
! SVE-NOT:     omp.barrier
! SVE:         return
! SSE-LABEL: func.func @_QPtest_isa_sse()
! SSE:         omp.barrier
! AVX-LABEL: func.func @_QPtest_isa_sse()
! AVX-NOT:     omp.barrier
! AVX:         return
! NONE-LABEL: func.func @_QPtest_isa_sse()
! NONE-NOT:     omp.barrier
! NONE:         return
subroutine test_isa_sse()
  !$omp metadirective &
  !$omp & when(device={isa("sse")}: barrier) &
#ifdef OMP_52
  !$omp & otherwise(nothing)
#else
  !$omp & default(nothing)
#endif
end subroutine

! NEON-LABEL: func.func @_QPtest_isa_avx()
! NEON-NOT:     omp.barrier
! NEON:         return
! SVE-LABEL: func.func @_QPtest_isa_avx()
! SVE-NOT:     omp.barrier
! SVE:         return
! SSE-LABEL: func.func @_QPtest_isa_avx()
! SSE-NOT:     omp.barrier
! SSE:         return
! AVX-LABEL: func.func @_QPtest_isa_avx()
! AVX:         omp.barrier
! NONE-LABEL: func.func @_QPtest_isa_avx()
! NONE-NOT:     omp.barrier
! NONE:         return
subroutine test_isa_avx()
  !$omp metadirective &
  !$omp & when(device={isa("avx")}: barrier) &
#ifdef OMP_52
  !$omp & otherwise(nothing)
#else
  !$omp & default(nothing)
#endif
end subroutine

! NEON-LABEL: func.func @_QPtest_isa_multi_when()
! NEON:         omp.barrier
! NEON-NOT:     omp.taskwait
! SVE-LABEL: func.func @_QPtest_isa_multi_when()
! SVE:         omp.barrier
! SVE-NOT:     omp.taskwait
! SSE-LABEL: func.func @_QPtest_isa_multi_when()
! SSE-NOT:     omp.barrier
! SSE:         omp.taskwait
! AVX-LABEL: func.func @_QPtest_isa_multi_when()
! AVX-NOT:     omp.barrier
! AVX-NOT:     omp.taskwait
! AVX:         return
! NONE-LABEL: func.func @_QPtest_isa_multi_when()
! NONE-NOT:     omp.barrier
! NONE-NOT:     omp.taskwait
! NONE:         return
subroutine test_isa_multi_when()
  !$omp metadirective &
  !$omp & when(device={isa("neon")}: barrier) &
  !$omp & when(device={isa("sse")}: taskwait) &
#ifdef OMP_52
  !$omp & otherwise(nothing)
#else
  !$omp & default(nothing)
#endif
end subroutine

! NEON-LABEL: func.func @_QPtest_isa_parallel_do()
! NEON:         omp.parallel
! NEON:           omp.wsloop
! SVE-LABEL: func.func @_QPtest_isa_parallel_do()
! SVE:         omp.parallel
! SVE:           omp.wsloop
! SSE-LABEL: func.func @_QPtest_isa_parallel_do()
! SSE-NOT:     omp.parallel
! SSE:         omp.wsloop
! AVX-LABEL: func.func @_QPtest_isa_parallel_do()
! AVX-NOT:     omp.parallel
! AVX:         omp.wsloop
! NONE-LABEL: func.func @_QPtest_isa_parallel_do()
! NONE-NOT:     omp.parallel
! NONE:         omp.wsloop
subroutine test_isa_parallel_do()
  integer :: i
  !$omp metadirective &
  !$omp & when(device={isa("neon")}: parallel do) &
#ifdef OMP_52
  !$omp & otherwise(do)
#else
  !$omp & default(do)
#endif
  do i = 1, 10
  end do
end subroutine

! NEON-LABEL: func.func @_QPtest_isa_no_match_default()
! NEON:         omp.barrier
! SVE-LABEL: func.func @_QPtest_isa_no_match_default()
! SVE:         omp.barrier
! SSE-LABEL: func.func @_QPtest_isa_no_match_default()
! SSE:         omp.barrier
! AVX-LABEL: func.func @_QPtest_isa_no_match_default()
! AVX:         omp.barrier
! NONE-LABEL: func.func @_QPtest_isa_no_match_default()
! NONE:         omp.barrier
subroutine test_isa_no_match_default()
  !$omp metadirective &
  !$omp & when(device={isa("sve2")}: taskwait) &
#ifdef OMP_52
  !$omp & otherwise(barrier)
#else
  !$omp & default(barrier)
#endif
end subroutine

! Below two functions was ported from clang/test/OpenMP/metadirective_device_isa_codegen_amdgcn.cpp

! AMDGCN-LABEL: func.func @_QPtest_amdgcn_device_isa_selected()
! AMDGCN:         omp.target
! AMDGCN:           omp.parallel {
! AMDGCN:             omp.wsloop {
! AMDGCN:               omp.loop_nest

! AMDGCN-LABEL: func.func @_QPtest_amdgcn_device_isa_not_selected()
! AMDGCN:         omp.target
! AMDGCN-NOT:     omp.parallel
! AMDGCN:           omp.wsloop {
! AMDGCN:             omp.loop_nest
subroutine test_amdgcn_device_isa_selected()
  integer, parameter :: n = 32
  integer :: i
  integer :: values(n)

  !$omp target map(tofrom: values)
    !$omp metadirective &
    !$omp & when(device={isa("dpp")}: parallel do) &
    !$omp & default(do)
    do i = 1, n
      values(i) = i
    end do
  !$omp end target
end subroutine

subroutine test_amdgcn_device_isa_not_selected()
  integer, parameter :: n = 32
  integer :: i
  integer :: values(n)

  !$omp target map(tofrom: values)
    !$omp metadirective &
    !$omp & when(device={isa("sse")}: parallel do) &
    !$omp & when(device={isa("another-unsupported-gpu-feature")}: parallel do) &
    !$omp & default(do)
    do i = 1, n
      values(i) = i
    end do
  !$omp end target
end subroutine
