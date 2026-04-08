! Test lowering of metadirective target_device arch selection inside a target
! region. This test is inspired by SOLLVE tests: test_metadirective_arch_is_nvidia.F90

! RUN: %flang_fc1 -cpp -DGPU_ARCH=amdgcn -fopenmp -emit-hlfir -fopenmp-version=50 %s -o - | FileCheck --check-prefixes=HOST,COMMON %s
! RUN: %flang_fc1 -cpp -DGPU_ARCH=spirv64 -fopenmp -emit-hlfir -fopenmp-version=50 %s -o - | FileCheck --check-prefixes=HOST,COMMON %s
! RUN: %if amdgpu-registered-target %{ %flang_fc1 -cpp -DGPU_ARCH=amdgcn -triple amdgcn-amd-amdhsa -fopenmp -emit-hlfir -fopenmp-version=50 -fopenmp-is-target-device %s -o - | FileCheck --check-prefixes=DEVICE,COMMON %s %}
! RUN: %if spirv-registered-target %{ %flang_fc1 -cpp -DGPU_ARCH=spirv64 -triple spirv64-intel -fopenmp -emit-hlfir -fopenmp-version=50 -fopenmp-is-target-device %s -o - | FileCheck --check-prefixes=DEVICE,COMMON %s %}

! COMMON-LABEL: func.func @_QPmetadirective_device_arch_codegen()

! HOST:         omp.target
! HOST-NOT:     omp.teams
! HOST:         omp.parallel
! HOST-NOT:     omp.distribute
! HOST:         omp.wsloop
! HOST:         omp.loop_nest

! DEVICE:       omp.target
! DEVICE:       omp.teams
! DEVICE:       omp.parallel
! DEVICE:       omp.distribute
! DEVICE:       omp.wsloop
! DEVICE:       omp.loop_nest
subroutine metadirective_device_arch_codegen()
  integer, parameter :: n = 1024
  integer :: i
  integer :: default_device
  real :: v1(n), v2(n), v3(n)

  !$omp target map(to:v1, v2) map(from:v3) device(default_device)
    !$omp metadirective &
    !$omp & when(target_device={arch(GPU_ARCH)}: teams distribute parallel do) &
    !$omp & default(parallel do)
    do i = 1, n
      v3(i) = v1(i) * v2(i)
    end do
  !$omp end target
end subroutine metadirective_device_arch_codegen
