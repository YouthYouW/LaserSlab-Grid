!!****if* source/Simulation/SimulationMain/LaserSlab/Simulation_data
!!
!! NAME
!!  Simulation_data
!!
!! SYNOPSIS
!!  Use Simulation_data
!!
!! DESCRIPTION
!!
!!  Store the simulation data
!!
!! 
!!***
module Simulation_data

  implicit none

#include "constants.h"

  !! *** Runtime Parameters *** !!  
  real, save :: sim_targetRadius
  real, save :: sim_targetHeight
  real, save :: sim_vacuumHeight

  real,    save :: sim_rhoTarg  
  real,    save :: sim_teleTarg 
  real,    save :: sim_tionTarg 
  real,    save :: sim_tradTarg 
  real,    save :: sim_zminTarg
  integer, save :: sim_eosTarg

  real,    save :: sim_rhoCham  
  real,    save :: sim_teleCham 
  real,    save :: sim_tionCham 
  real,    save :: sim_tradCham 
  integer, save :: sim_eosCham  

  logical, save :: sim_killdivb = .FALSE.
  real, save :: sim_smallX
  character(len=MAX_STRING_LENGTH), save :: sim_initGeom

  logical, save :: sim_useRefineSpecialized = .FALSE.
  integer, save :: criterion
  integer, save :: size
  integer, save :: lref
  real,    save :: specs(7)
  real,    save :: spec_1
  real,    save :: spec_2
  real,    save :: spec_3
  real,    save :: spec_4
  real,    save :: spec_5
  real,    save :: spec_6
  real,    save :: spec_7

  ! ===== OUR GEOMETRIC REFINEMENT PARAMETERS (RENAMED and CORRECTED) =====
  logical, save :: sim_useGeometryRefinement = .FALSE.
  integer, save :: sim_geom_refine_nregions
  
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape(12)
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_1
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_2
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_3
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_4
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_5
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_6
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_7
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_8
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_9
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_10
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_11
  character(len=MAX_STRING_LENGTH), save :: sim_geom_refine_shape_12

  integer, save :: sim_geom_refine_level(12)
  integer, save :: sim_geom_refine_level_1
  integer, save :: sim_geom_refine_level_2
  integer, save :: sim_geom_refine_level_3
  integer, save :: sim_geom_refine_level_4
  integer, save :: sim_geom_refine_level_5
  integer, save :: sim_geom_refine_level_6
  integer, save :: sim_geom_refine_level_7
  integer, save :: sim_geom_refine_level_8
  integer, save :: sim_geom_refine_level_9
  integer, save :: sim_geom_refine_level_10
  integer, save :: sim_geom_refine_level_11
  integer, save :: sim_geom_refine_level_12

  real,    save :: sim_geom_refine_center_x(12)
  real,    save :: sim_geom_refine_center_x_1
  real,    save :: sim_geom_refine_center_x_2
  real,    save :: sim_geom_refine_center_x_3
  real,    save :: sim_geom_refine_center_x_4
  real,    save :: sim_geom_refine_center_x_5
  real,    save :: sim_geom_refine_center_x_6
  real,    save :: sim_geom_refine_center_x_7
  real,    save :: sim_geom_refine_center_x_8
  real,    save :: sim_geom_refine_center_x_9
  real,    save :: sim_geom_refine_center_x_10
  real,    save :: sim_geom_refine_center_x_11
  real,    save :: sim_geom_refine_center_x_12

  real,    save :: sim_geom_refine_center_y(12)
  real,    save :: sim_geom_refine_center_y_1
  real,    save :: sim_geom_refine_center_y_2
  real,    save :: sim_geom_refine_center_y_3
  real,    save :: sim_geom_refine_center_y_4
  real,    save :: sim_geom_refine_center_y_5
  real,    save :: sim_geom_refine_center_y_6
  real,    save :: sim_geom_refine_center_y_7
  real,    save :: sim_geom_refine_center_y_8
  real,    save :: sim_geom_refine_center_y_9
  real,    save :: sim_geom_refine_center_y_10
  real,    save :: sim_geom_refine_center_y_11
  real,    save :: sim_geom_refine_center_y_12

  real,    save :: sim_geom_refine_center_z(12)
  real,    save :: sim_geom_refine_center_z_1
  real,    save :: sim_geom_refine_center_z_2
  real,    save :: sim_geom_refine_center_z_3
  real,    save :: sim_geom_refine_center_z_4
  real,    save :: sim_geom_refine_center_z_5
  real,    save :: sim_geom_refine_center_z_6
  real,    save :: sim_geom_refine_center_z_7
  real,    save :: sim_geom_refine_center_z_8
  real,    save :: sim_geom_refine_center_z_9
  real,    save :: sim_geom_refine_center_z_10
  real,    save :: sim_geom_refine_center_z_11
  real,    save :: sim_geom_refine_center_z_12

  real,    save :: sim_geom_refine_size_x(12)
  real,    save :: sim_geom_refine_size_x_1
  real,    save :: sim_geom_refine_size_x_2
  real,    save :: sim_geom_refine_size_x_3
  real,    save :: sim_geom_refine_size_x_4
  real,    save :: sim_geom_refine_size_x_5
  real,    save :: sim_geom_refine_size_x_6
  real,    save :: sim_geom_refine_size_x_7
  real,    save :: sim_geom_refine_size_x_8
  real,    save :: sim_geom_refine_size_x_9
  real,    save :: sim_geom_refine_size_x_10
  real,    save :: sim_geom_refine_size_x_11
  real,    save :: sim_geom_refine_size_x_12

  real,    save :: sim_geom_refine_size_y(12)
  real,    save :: sim_geom_refine_size_y_1
  real,    save :: sim_geom_refine_size_y_2
  real,    save :: sim_geom_refine_size_y_3
  real,    save :: sim_geom_refine_size_y_4
  real,    save :: sim_geom_refine_size_y_5
  real,    save :: sim_geom_refine_size_y_6
  real,    save :: sim_geom_refine_size_y_7
  real,    save :: sim_geom_refine_size_y_8
  real,    save :: sim_geom_refine_size_y_9
  real,    save :: sim_geom_refine_size_y_10
  real,    save :: sim_geom_refine_size_y_11
  real,    save :: sim_geom_refine_size_y_12

  real,    save :: sim_geom_refine_size_z(12)
  real,    save :: sim_geom_refine_size_z_1
  real,    save :: sim_geom_refine_size_z_2
  real,    save :: sim_geom_refine_size_z_3
  real,    save :: sim_geom_refine_size_z_4
  real,    save :: sim_geom_refine_size_z_5
  real,    save :: sim_geom_refine_size_z_6
  real,    save :: sim_geom_refine_size_z_7
  real,    save :: sim_geom_refine_size_z_8
  real,    save :: sim_geom_refine_size_z_9
  real,    save :: sim_geom_refine_size_z_10
  real,    save :: sim_geom_refine_size_z_11
  real,    save :: sim_geom_refine_size_z_12
  
  ! =====================================================================

end module Simulation_data


