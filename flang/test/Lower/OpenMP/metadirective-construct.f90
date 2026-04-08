! Test metadirective with construct trait selectors.

! RUN: split-file %s %t

! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=50 %t/default.f90 -o - | FileCheck --check-prefix=DEFAULT %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=51 %t/default.f90 -o - | FileCheck --check-prefix=DEFAULT %s
! RUN: %flang_fc1 -fopenmp -emit-hlfir -fopenmp-version=52 %t/otherwise.f90 -o - | FileCheck --check-prefix=OTHERWISE %s

!--- default.f90
subroutine test_construct_parallel()
  !$omp parallel
  !$omp metadirective &
  !$omp & when(construct={parallel}: taskwait) &
  !$omp & default(nothing)
  !$omp end parallel
end subroutine

subroutine test_construct_single()
  !$omp parallel
  !$omp single
  !$omp metadirective &
  !$omp & when(construct={single}: taskwait) &
  !$omp & default(nothing)
  !$omp end single
  !$omp end parallel
end subroutine

subroutine test_construct_no_match()
  !$omp parallel
  !$omp metadirective &
  !$omp & when(construct={target}: taskyield) &
  !$omp & default(nothing)
  !$omp end parallel
end subroutine

subroutine test_construct_parallel_do()
  integer :: i
  ! Inside parallel do — construct={parallel do} should match in the loop body.
  !$omp parallel do
  do i = 1, 10
    !$omp metadirective &
    !$omp & when(construct={parallel do}: taskwait) &
    !$omp & default(nothing)
  end do
  !$omp end parallel do
end subroutine

subroutine test_construct_target()
  !$omp target
  !$omp metadirective &
  !$omp & when(construct={target}: taskwait) &
  !$omp & default(nothing)
  !$omp end target
end subroutine

subroutine test_construct_target_parallel()
  !$omp target parallel
  !$omp metadirective &
  !$omp & when(construct={target parallel}: taskwait) &
  !$omp & default(nothing)
  !$omp end target parallel
end subroutine

subroutine test_construct_target_parallel_do()
  integer :: i
  !$omp target parallel do
  do i = 1, 10
    !$omp metadirective &
    !$omp & when(construct={target parallel do}: taskyield) &
    !$omp & default(nothing)
  end do
  !$omp end target parallel do
end subroutine

subroutine test_construct_target_teams()
  !$omp target teams
  !$omp metadirective &
  !$omp & when(construct={target teams}: taskwait) &
  !$omp & default(nothing)
  !$omp end target teams
end subroutine

subroutine test_construct_target_teams_distribute()
  integer :: i
  !$omp target teams distribute
  do i = 1, 10
    !$omp metadirective &
    !$omp & when(construct={target teams distribute}: taskyield) &
    !$omp & default(nothing)
  end do
  !$omp end target teams distribute
end subroutine

subroutine test_construct_target_teams_distribute_parallel_do()
  integer :: i
  !$omp target teams distribute parallel do
  do i = 1, 10
    !$omp metadirective &
    !$omp & when(construct={target teams distribute parallel do}: taskwait) &
    !$omp & default(nothing)
  end do
  !$omp end target teams distribute parallel do
end subroutine

subroutine test_construct_multi_region()
  integer :: i
  ! The earlier parallel do has ended before the metadirective and must not
  ! satisfy construct={parallel}. Only the second parallel actively encloses
  ! the metadirective, so that is the construct that should match.
  !$omp parallel do
  do i = 1, 10
  end do
  !$omp end parallel do
  !$omp parallel
  !$omp metadirective &
  !$omp & when(construct={parallel}: taskyield) &
  !$omp & default(nothing)
  !$omp end parallel
end subroutine

subroutine test_construct_sections()
  !$omp parallel sections
  !$omp section
  !$omp metadirective &
  !$omp & when(construct={sections}: taskwait) &
  !$omp & default(nothing)
  !$omp end parallel sections
end subroutine

subroutine test_construct_critical()
  !$omp critical
  !$omp metadirective &
  !$omp & when(construct={critical}: taskyield) &
  !$omp & default(nothing)
  !$omp end critical
end subroutine

subroutine test_construct_not_enclosing()
  !$omp metadirective &
  !$omp & when(construct={parallel}: taskwait) &
  !$omp & default(nothing)
end subroutine

!--- otherwise.f90
subroutine test_construct_parallel()
  !$omp parallel
  !$omp metadirective &
  !$omp & when(construct={parallel}: taskwait) &
  !$omp & otherwise(nothing)
  !$omp end parallel
end subroutine

subroutine test_construct_single()
  !$omp parallel
  !$omp single
  !$omp metadirective &
  !$omp & when(construct={single}: taskwait) &
  !$omp & otherwise(nothing)
  !$omp end single
  !$omp end parallel
end subroutine

subroutine test_construct_no_match()
  ! Should lower to nothing
  !$omp parallel
  !$omp metadirective &
  !$omp & when(construct={target}: taskyield) &
  !$omp & otherwise(nothing)
  !$omp end parallel
end subroutine

subroutine test_construct_parallel_do()
  integer :: i
  !$omp parallel do
  do i = 1, 10
    !$omp metadirective &
    !$omp & when(construct={parallel do}: taskwait) &
    !$omp & otherwise(nothing)
  end do
  !$omp end parallel do
end subroutine

subroutine test_construct_target()
  !$omp target
  !$omp metadirective &
  !$omp & when(construct={target}: taskwait) &
  !$omp & otherwise(nothing)
  !$omp end target
end subroutine

subroutine test_construct_target_parallel()
  !$omp target parallel
  !$omp metadirective &
  !$omp & when(construct={target parallel}: taskwait) &
  !$omp & otherwise(nothing)
  !$omp end target parallel
end subroutine

subroutine test_construct_target_parallel_do()
  integer :: i
  !$omp target parallel do
  do i = 1, 10
    !$omp metadirective &
    !$omp & when(construct={target parallel do}: taskyield) &
    !$omp & otherwise(nothing)
  end do
  !$omp end target parallel do
end subroutine

subroutine test_construct_target_teams()
  !$omp target teams
  !$omp metadirective &
  !$omp & when(construct={target teams}: taskwait) &
  !$omp & otherwise(nothing)
  !$omp end target teams
end subroutine

subroutine test_construct_target_teams_distribute()
  integer :: i
  !$omp target teams distribute
  do i = 1, 10
    !$omp metadirective &
    !$omp & when(construct={target teams distribute}: taskyield) &
    !$omp & otherwise(nothing)
  end do
  !$omp end target teams distribute
end subroutine

subroutine test_construct_target_teams_distribute_parallel_do()
  integer :: i
  !$omp target teams distribute parallel do
  do i = 1, 10
    !$omp metadirective &
    !$omp & when(construct={target teams distribute parallel do}: taskwait) &
    !$omp & otherwise(nothing)
  end do
  !$omp end target teams distribute parallel do
end subroutine

subroutine test_construct_sections()
  !$omp parallel sections
  !$omp section
  !$omp metadirective &
  !$omp & when(construct={sections}: taskwait) &
  !$omp & otherwise(nothing)
  !$omp end parallel sections
end subroutine

subroutine test_construct_critical()
  !$omp critical
  !$omp metadirective &
  !$omp & when(construct={critical}: taskyield) &
  !$omp & otherwise(nothing)
  !$omp end critical
end subroutine

subroutine test_construct_not_enclosing()
  ! No enclosing parallel, fall through to otherwise(taskwait).
  !$omp metadirective &
  !$omp & when(construct={parallel}: nothing) &
  !$omp & otherwise(taskwait)
end subroutine

! DEFAULT-LABEL: func.func @_QPtest_construct_parallel()
! DEFAULT:         omp.parallel {
! DEFAULT:           omp.taskwait
! DEFAULT:           omp.terminator
! DEFAULT:         }

! DEFAULT-LABEL: func.func @_QPtest_construct_single()
! DEFAULT:         omp.parallel {
! DEFAULT:           omp.single {
! DEFAULT:             omp.taskwait
! DEFAULT:             omp.terminator
! DEFAULT:           omp.terminator
! DEFAULT:         }

! DEFAULT-LABEL: func.func @_QPtest_construct_no_match()
! DEFAULT-NOT:     omp.parallel
! DEFAULT-NOT:     omp.taskyield
! DEFAULT:         return

! DEFAULT-LABEL: func.func @_QPtest_construct_parallel_do()
! DEFAULT:         omp.parallel {
! DEFAULT:           omp.wsloop
! DEFAULT:             omp.loop_nest
! DEFAULT:               omp.taskwait
! DEFAULT:               omp.yield
! DEFAULT:           omp.terminator
! DEFAULT:         }

! DEFAULT-LABEL: func.func @_QPtest_construct_target()
! DEFAULT:         omp.target {
! DEFAULT:           omp.taskwait
! DEFAULT:           omp.terminator
! DEFAULT:         }

! DEFAULT-LABEL: func.func @_QPtest_construct_target_parallel()
! DEFAULT:         omp.target {
! DEFAULT:           omp.parallel {
! DEFAULT:             omp.taskwait
! DEFAULT:             omp.terminator
! DEFAULT:           omp.terminator
! DEFAULT:         }

! DEFAULT-LABEL: func.func @_QPtest_construct_target_parallel_do()
! DEFAULT:         omp.target
! DEFAULT:           omp.parallel {
! DEFAULT:             omp.wsloop
! DEFAULT:               omp.loop_nest
! DEFAULT:                 omp.taskyield

! DEFAULT-LABEL: func.func @_QPtest_construct_target_teams()
! DEFAULT:         omp.target {
! DEFAULT:           omp.teams {
! DEFAULT:             omp.taskwait
! DEFAULT:             omp.terminator
! DEFAULT:           omp.terminator
! DEFAULT:         }

! DEFAULT-LABEL: func.func @_QPtest_construct_target_teams_distribute()
! DEFAULT:         omp.target
! DEFAULT:           omp.teams {
! DEFAULT:             omp.distribute
! DEFAULT:               omp.loop_nest
! DEFAULT:                 omp.taskyield

! DEFAULT-LABEL: func.func @_QPtest_construct_target_teams_distribute_parallel_do()
! DEFAULT:         omp.target
! DEFAULT:           omp.teams {
! DEFAULT:             omp.parallel
! DEFAULT:               omp.distribute
! DEFAULT:                 omp.wsloop
! DEFAULT:                   omp.loop_nest
! DEFAULT:                     omp.taskwait

! DEFAULT-LABEL: func.func @_QPtest_construct_multi_region()
! DEFAULT:         omp.parallel {
! DEFAULT:           omp.wsloop
! DEFAULT:             omp.loop_nest
! DEFAULT:           omp.terminator
! DEFAULT:         }
! DEFAULT:         omp.parallel {
! DEFAULT:           omp.taskyield
! DEFAULT:           omp.terminator
! DEFAULT:         }

! DEFAULT-LABEL: func.func @_QPtest_construct_sections()
! DEFAULT:         omp.parallel {
! DEFAULT:           omp.sections {
! DEFAULT:             omp.section {
! DEFAULT:               omp.taskwait
! DEFAULT:               omp.terminator
! DEFAULT:             omp.terminator
! DEFAULT:           omp.terminator
! DEFAULT:         }

! DEFAULT-LABEL: func.func @_QPtest_construct_critical()
! DEFAULT:         omp.critical {
! DEFAULT:           omp.taskyield
! DEFAULT:           omp.terminator
! DEFAULT:         }

! DEFAULT-LABEL: func.func @_QPtest_construct_not_enclosing()
! DEFAULT-NOT:     omp.taskwait
! DEFAULT:         return

! OTHERWISE-LABEL: func.func @_QPtest_construct_parallel()
! OTHERWISE:         omp.parallel {
! OTHERWISE:           omp.taskwait
! OTHERWISE:           omp.terminator
! OTHERWISE:         }

! OTHERWISE-LABEL: func.func @_QPtest_construct_single()
! OTHERWISE:         omp.parallel {
! OTHERWISE:           omp.single {
! OTHERWISE:             omp.taskwait
! OTHERWISE:             omp.terminator
! OTHERWISE:           omp.terminator
! OTHERWISE:         }

! OTHERWISE-LABEL: func.func @_QPtest_construct_no_match()
! OTHERWISE-NOT:     omp.parallel
! OTHERWISE-NOT:     omp.taskyield
! OTHERWISE:         return

! OTHERWISE-LABEL: func.func @_QPtest_construct_parallel_do()
! OTHERWISE:         omp.parallel {
! OTHERWISE:           omp.wsloop
! OTHERWISE:             omp.loop_nest
! OTHERWISE:               omp.taskwait
! OTHERWISE:               omp.yield
! OTHERWISE:           omp.terminator
! OTHERWISE:         }

! OTHERWISE-LABEL: func.func @_QPtest_construct_target()
! OTHERWISE:         omp.target {
! OTHERWISE:           omp.taskwait
! OTHERWISE:           omp.terminator
! OTHERWISE:         }

! OTHERWISE-LABEL: func.func @_QPtest_construct_target_parallel()
! OTHERWISE:         omp.target {
! OTHERWISE:           omp.parallel {
! OTHERWISE:             omp.taskwait
! OTHERWISE:             omp.terminator
! OTHERWISE:           omp.terminator
! OTHERWISE:         }

! OTHERWISE-LABEL: func.func @_QPtest_construct_target_parallel_do()
! OTHERWISE:         omp.target
! OTHERWISE:           omp.parallel {
! OTHERWISE:             omp.wsloop
! OTHERWISE:               omp.loop_nest
! OTHERWISE:                 omp.taskyield

! OTHERWISE-LABEL: func.func @_QPtest_construct_target_teams()
! OTHERWISE:         omp.target {
! OTHERWISE:           omp.teams {
! OTHERWISE:             omp.taskwait
! OTHERWISE:             omp.terminator
! OTHERWISE:           omp.terminator
! OTHERWISE:         }

! OTHERWISE-LABEL: func.func @_QPtest_construct_target_teams_distribute()
! OTHERWISE:         omp.target
! OTHERWISE:           omp.teams {
! OTHERWISE:             omp.distribute
! OTHERWISE:               omp.loop_nest
! OTHERWISE:                 omp.taskyield

! OTHERWISE-LABEL: func.func @_QPtest_construct_target_teams_distribute_parallel_do()
! OTHERWISE:         omp.target
! OTHERWISE:           omp.teams {
! OTHERWISE:             omp.parallel
! OTHERWISE:               omp.distribute
! OTHERWISE:                 omp.wsloop
! OTHERWISE:                   omp.loop_nest
! OTHERWISE:                     omp.taskwait

! OTHERWISE-LABEL: func.func @_QPtest_construct_sections()
! OTHERWISE:         omp.parallel {
! OTHERWISE:           omp.sections {
! OTHERWISE:             omp.section {
! OTHERWISE:               omp.taskwait
! OTHERWISE:               omp.terminator
! OTHERWISE:             omp.terminator
! OTHERWISE:           omp.terminator
! OTHERWISE:         }

! OTHERWISE-LABEL: func.func @_QPtest_construct_critical()
! OTHERWISE:         omp.critical {
! OTHERWISE:           omp.taskyield
! OTHERWISE:           omp.terminator
! OTHERWISE:         }

! OTHERWISE-LABEL: func.func @_QPtest_construct_not_enclosing()
! OTHERWISE:         omp.taskwait
! OTHERWISE:         return
