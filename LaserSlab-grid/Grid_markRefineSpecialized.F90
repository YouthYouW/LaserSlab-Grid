!!****if* sim/YourProblem/Grid_markRefineSpecialized
!!
!! NAME
!!  Grid_markRefineSpecialized
!!
!! DESCRIPTION 
!!  This file OVERRIDES the default implementation. It uses pre-loaded
!!  parameters from the Simulation_data module to apply a multi-region
!!  geometric refinement strategy.
!!
!!  This version has been refactored to use the robust block-overlap
!!  detection method, similar to the official gr_markInRectangle routine.
!!  It correctly checks if a block's bounding box overlaps with the
!!  specified refinement regions ('box' or 'sphere'), rather than just
!!  checking the block's center point. This ensures that large,
!!  low-resolution blocks that partially enter a refinement zone are
!!  correctly marked for refinement.
!!
!!***

subroutine Grid_markRefineSpecialized(criterion_arg, size_arg, specs_arg, lref_arg)
   use Simulation_data, ONLY : sim_useGeometryRefinement, sim_geom_refine_nregions, &
                               sim_geom_refine_shape, sim_geom_refine_level, &
                               sim_geom_refine_center_x, sim_geom_refine_center_y, sim_geom_refine_center_z, &
                               sim_geom_refine_size_x, sim_geom_refine_size_y, sim_geom_refine_size_z
   
   use tree, ONLY : refine, derefine, lrefine, bsize, coord, nodetype, lnblocks
 
   implicit none
 
#include "constants.h"
#include "Flash.h"
 
   ! Arguments passed by the framework (we don't use them)
   integer, intent(in) :: criterion_arg, size_arg, lref_arg
   real, dimension(size_arg), intent(in) :: specs_arg
   
   ! --- Local variable declarations (inspired by gr_markInRectangle) ---
   integer :: i, b, target_lref

   ! Block geometry variables
   real, dimension(MDIM) :: blockCenter, blockSize
   real                  :: xl, xr, yl, yr, zl, zr

   ! Region geometry variables
   real                  :: ilb, irb, jlb, jrb, klb, krb
   real, dimension(MDIM) :: regionCenter
   real                  :: sphereRadiusSq, distSq
   real, dimension(MDIM) :: closestPoint

   ! Logical flags for overlap detection
   logical               :: in_region
   logical               :: x_overlaps, y_overlaps, z_overlaps
   
   ! If the feature is not turned on, do nothing.
   if (.not. sim_useGeometryRefinement) return
   if (sim_geom_refine_nregions <= 0) return
 
   ! Loop over all blocks on this processor
   do b = 1, lnblocks
     
     if (nodetype(b) == LEAF) then
       
       ! --- 1. Calculate block's bounding box (done once per block) ---
       ! This logic is taken directly from gr_markInRectangle
       blockCenter = coord(:,b)
       blockSize   = 0.5 * bsize(:,b)
        
       xl = blockCenter(1) - blockSize(1)
       xr = blockCenter(1) + blockSize(1)

       ! Handle different dimensions safely
       if (NDIM >= 2) then
          yl = blockCenter(2) - blockSize(2)
          yr = blockCenter(2) + blockSize(2)
       endif
       if (NDIM == 3) then
          zl = blockCenter(3) - blockSize(3)
          zr = blockCenter(3) + blockSize(3)
       endif
       
       ! --- 2. Determine the highest required refinement level for this block ---
       ! Initialize with 0 (or a global minimum refinement level if you have one)
       target_lref = 0 
       
       ! Loop through all defined geometric refinement regions
       do i = 1, sim_geom_refine_nregions

         in_region = .false.

         if (trim(sim_geom_refine_shape(i)) == 'box') then
           ! --- 'box' shape: Check for overlap with the rectangular region ---
           
           ! Define the refinement rectangle's bounds.
           ! NOTE: Assuming sim_geom_refine_size_* are HALF-widths of the box.
           ilb = sim_geom_refine_center_x(i) - sim_geom_refine_size_x(i)
           irb = sim_geom_refine_center_x(i) + sim_geom_refine_size_x(i)
           
           ! This is the core logic from gr_markInRectangle for overlap detection.
           ! A block overlaps if it's NOT entirely to the left OR entirely to the right.
           x_overlaps = .not. ((xr <= ilb) .or. (xl >= irb))
           
           if (NDIM >= 2) then
              jlb = sim_geom_refine_center_y(i) - sim_geom_refine_size_y(i)
              jrb = sim_geom_refine_center_y(i) + sim_geom_refine_size_y(i)
              y_overlaps = .not. ((yr <= jlb) .or. (yl >= jrb))
           else
              y_overlaps = .true. ! In 1D, this dimension always "overlaps"
           endif
           
           if (NDIM == 3) then
              klb = sim_geom_refine_center_z(i) - sim_geom_refine_size_z(i)
              krb = sim_geom_refine_center_z(i) + sim_geom_refine_size_z(i)
              z_overlaps = .not. ((zr <= klb) .or. (zl >= krb))
           else
              z_overlaps = .true. ! In 1D/2D, this dimension always "overlaps"
           endif
           
           if (x_overlaps .and. y_overlaps .and. z_overlaps) then
              in_region = .true.
           endif

         else if (trim(sim_geom_refine_shape(i)) == 'sphere') then
           ! --- 'sphere' shape: Check for overlap between the sphere and the block's bounding box ---
           ! This is more accurate than just checking the block center.
           
           regionCenter(1) = sim_geom_refine_center_x(i)
           sphereRadiusSq  = sim_geom_refine_size_x(i)**2 ! Assuming size_x is the radius

           if (NDIM >= 2) regionCenter(2) = sim_geom_refine_center_y(i)
           if (NDIM == 3) regionCenter(3) = sim_geom_refine_center_z(i)
           
           ! Find the point within the block's bounding box that is closest to the sphere's center.
           closestPoint(1) = max(xl, min(xr, regionCenter(1)))
           if (NDIM >= 2) closestPoint(2) = max(yl, min(yr, regionCenter(2)))
           if (NDIM == 3) closestPoint(3) = max(zl, min(zr, regionCenter(3)))

           ! Calculate the squared distance from this closest point to the sphere's center.
           distSq = (closestPoint(1) - regionCenter(1))**2
           if (NDIM >= 2) distSq = distSq + (closestPoint(2) - regionCenter(2))**2
           if (NDIM == 3) distSq = distSq + (closestPoint(3) - regionCenter(3))**2
           
           ! If the distance is less than the radius, the sphere and block intersect.
           if (distSq <= sphereRadiusSq) then
             in_region = .true.
           endif
         endif

         ! --- 3. Update target_lref if the block is in the current region ---
         ! If a block is in multiple regions, it takes on the highest refinement level.
         if (in_region) then
            target_lref = max(target_lref, sim_geom_refine_level(i))
         endif

       end do ! End of regions loop
       
       ! --- 4. Mark the block for refinement or derefinement based on the final target level ---
       ! This logic is robust: it refines if below target, derefines if above.
       if (lrefine(b) < target_lref) then
         refine(b) = .true.
         derefine(b) = .false. ! Ensure we don't try to do both
       else if (lrefine(b) > target_lref) then
         derefine(b) = .true.
         refine(b) = .false. ! Ensure we don't try to do both
       endif
       
     endif ! End of LEAF node check
   end do ! End of block loop
 
   return
 end subroutine Grid_markRefineSpecialized