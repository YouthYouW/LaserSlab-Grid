!!****if* source/Simulation/SimulationMain/LaserSlab/Simulation_init
!!
!! NAME
!!
!!  Simulation_init
!!
!!
!! SYNOPSIS
!!
!!  Simulation_init()
!!
!!
!! DESCRIPTION
!!
!!  Initializes all the parameters needed for a particular simulation
!!
!!
!! ARGUMENTS
!!
!!  
!!
!! PARAMETERS
!!
!!***

subroutine Simulation_init()
  use Simulation_data
  use RuntimeParameters_interface, ONLY : RuntimeParameters_get
  use Logfile_interface, ONLY : Logfile_stamp
  
  implicit none

#include "constants.h"
#include "Flash.h"

  real :: xmin, xmax, ymin, ymax
  integer :: lrefine_max, nblockx, nblocky
  character(len=MAX_STRING_LENGTH) :: str
  character(len=MAX_STRING_LENGTH) :: parameterString
  integer :: i

  call RuntimeParameters_get('sim_targetRadius', sim_targetRadius)
  call RuntimeParameters_get('sim_targetHeight', sim_targetHeight)
  call RuntimeParameters_get('sim_vacuumHeight', sim_vacuumHeight)
  
  call RuntimeParameters_get('sim_rhoTarg', sim_rhoTarg)
  call RuntimeParameters_get('sim_teleTarg', sim_teleTarg)
  call RuntimeParameters_get('sim_tionTarg', sim_tionTarg)
  call RuntimeParameters_get('sim_tradTarg', sim_tradTarg)

  call RuntimeParameters_get('sim_rhoCham', sim_rhoCham)
  call RuntimeParameters_get('sim_teleCham', sim_teleCham)
  call RuntimeParameters_get('sim_tionCham', sim_tionCham)
  call RuntimeParameters_get('sim_tradCham', sim_tradCham)

  call RuntimeParameters_get('smallX', sim_smallX)

  call RuntimeParameters_get('sim_initGeom', sim_initGeom)

#ifdef FLASH_USM_MHD
  call RuntimeParameters_get('killdivb', sim_killdivb)
#endif

  call RuntimeParameters_get('sim_useRefineSpecialized', sim_useRefineSpecialized)
  if (sim_useRefineSpecialized) then
    call RuntimeParameters_get('size', size)
    call RuntimeParameters_get('criterion', criterion)
    call RuntimeParameters_get('lref', lref)
    do i=1, size
      write (parameterString, '(a,i0)') 'spec_', i
      call RuntimeParameters_get(parameterString, specs(i))
    end do
  end if

  ! ===== READ OUR GEOMETRIC REFINEMENT PARAMETERS (REVISED LOGIC) =====
  call RuntimeParameters_get('sim_useGeometryRefinement', sim_useGeometryRefinement)
  
  if (sim_useGeometryRefinement) then
    call RuntimeParameters_get('sim_geom_refine_nregions', sim_geom_refine_nregions)
    
    ! Check if the number of regions exceeds our array size in Fortran
    if (sim_geom_refine_nregions > 12) then
       call Driver_abortFlash("Error: sim_geom_refine_nregions exceeds 12 limit.")
    end if
    
    do i = 1, sim_geom_refine_nregions
      ! Read shape
      write (parameterString,'(a,i0)') "sim_geom_refine_shape_", i
      call RuntimeParameters_get(parameterString, sim_geom_refine_shape(i))
      
      ! Read level
      write (parameterString,'(a,i0)') "sim_geom_refine_level_", i
      call RuntimeParameters_get(parameterString, sim_geom_refine_level(i))

      ! Read center coordinates
      write (parameterString,'(a,i0)') "sim_geom_refine_center_x_", i
      call RuntimeParameters_get(parameterString, sim_geom_refine_center_x(i))

      write (parameterString,'(a,i0)') "sim_geom_refine_center_y_", i
      call RuntimeParameters_get(parameterString, sim_geom_refine_center_y(i))

      write (parameterString,'(a,i0)') "sim_geom_refine_center_z_", i
      call RuntimeParameters_get(parameterString, sim_geom_refine_center_z(i))
      
      ! Read size parameters
      write (parameterString,'(a,i0)') "sim_geom_refine_size_x_", i
      call RuntimeParameters_get(parameterString, sim_geom_refine_size_x(i))
      
      write (parameterString,'(a,i0)') "sim_geom_refine_size_y_", i
      call RuntimeParameters_get(parameterString, sim_geom_refine_size_y(i))
      
      write (parameterString,'(a,i0)') "sim_geom_refine_size_z_", i
      call RuntimeParameters_get(parameterString, sim_geom_refine_size_z(i))
    end do
  end if
  ! =================================================================

end subroutine Simulation_init
