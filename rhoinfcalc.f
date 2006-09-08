c___c___c___c___c___c___c___c___c___c___c___c___c___c___c___c___c___c___
c
c This code is copyright(c) (2003-5) Ian H Hutchinson hutch@psfc.mit.edu
c
c  It may be used freely with the stipulation that any scientific or
c scholarly publication concerning work that uses the code must give an
c acknowledgement referring to the papers I.H.Hutchinson, Plasma Physics
c and Controlled Fusion, vol 44, p 1953 (2002), vol 45, p 1477 (2003).
c  The code may not be redistributed except in its original package.
c
c No warranty, explicit or implied, is given. If you choose to build
c or run the code, you do so at your own risk.
c
c Version Jul 2006
c___c___c___c___c___c___c___c___c___c___c___c___c___c___c___c___c___c___
c***********************************************************************
c Calculate the density at infinity based on the number of injections
c per step. 
      subroutine rhoinfcalc(dt,icolntype,colnwt)
      real dt
      integer icolntype
      real colnwt
      include 'piccom.f'
      include 'fvcom.f'
      real riave
      save

c This allows us to restart with nstepsave .ne. 1 if rhoinf is set.
      if(riave.eq.0)riave=rhoinf
      if(finnerave.eq.0)finnerave=ninner

      if(nrein .gt. 0) then
c Combination equivalent to phihere usage.
c The following statement requires us to call this routine after 
c (part at least of) chargediag has been done. 
         averein=(diagphi(NRFULL)+diagphi(NRUSED))*.5
         if(averein.gt.0.5*Ti)then
c This is necessary to prevent smaxflux errors. smaxflux is not correct
c for repulsive potentials.
c            write(*,*)'Excessive averein',averein,' capped'
            averein=0.5*Ti
         endif

c     We have to calculate rhoinf consistently with the reinjection

         if(icolntype.eq.1) then
c Using general fvinject, injecting at the computational boundary.
c  qthfv(nthfvsize) contains the one-way flux density
c integrated dcos(theta) in 2Ti-normalized units.
            riest=(nrein/dt) /
     $           (sqrt(2.*Ti)*
     $           qthfv(nthfvsize)*2.*3.141593
     $           *r(NRFULL)**2 )
c Hack up the effect of attracting edge potential.
c This extra term is not correct for large collisionality and probably 
c should not be applied. However, it does then give the same answer as 
c the kt2 approach.
c     $           /(1-averein/(Ti+0.*vd**2))
c Correction for collisional drag in outer region. Usually negligible.
            riest=riest
     $           +finnerave*colnwt/(4.*3.1415926*dt*(1.+Ti)*r(NRFULL))
         elseif(icolntype.eq.2)then
c ogeninject from infinity with a general distribution numerically
c Flux/(2\pi riest v_n rmax^2) = pu1(1) - averein*pu2(1)
            riest=(nrein/dt) /
     $           (sqrt(2.*Ti)*
     $           2.*3.1415926**2*(pu1(1)-pu2(1)*averein/Ti)
     $           *r(NRFULL)**2 )
c Correction for collisional drag solution in outer region.
            riest=riest
     $           +finnerave*colnwt/(4.*3.1415926*dt*(1.+Ti)*r(NRFULL))
c last is correction for diffusion.
         elseif (bcr.eq.0) then
c smaxflux returns total flux in units of Ti (not 2Ti)
            riest=(nrein/dt) /
     $           (sqrt(Ti)*
     $           smaxflux(vd/sqrt(2.*Ti),(-averein/Ti))
     $           *r(NRFULL)**2 )
         elseif (bcr.eq.1) then
            riest=(nrein/dt) /
     $           (sqrt(Ti)*
     $           smaxflux(vd/sqrt(2.*Ti),(-averein/Ti))
     $           *r(NRFULL)**2 )
         elseif (bcr.eq.2) then
            riest=(nreintry/dt) /
     $           (sqrt(Ti)*
     $           smaxflux(vd/sqrt(2.*Ti),(-averein/Ti))
     $           *r(NRFULL)**2 )
c            write(*,*) riest
         endif

c         write(*,*)'nrein=',nrein,
c     $        '  averein=',averein,' riest=',riest
      else
c If no valid estimate, just keep it the same.
c         write(*,*) 'nrein=0'
         if(.not. rhoinf.gt.1.e-4)then
            write(*,*)'rhoinf error in chargediag:',rhoinf,
     $           ' approximated.'
c estimate rhoinf approximately:
            rhoinf=numprocs*npart/(4.*pi*r(NRFULL)**3/3.)
         endif
         averein=0.
         riest=rhoinf
      endif
c Average the flux of particles to the inner, because it's a small number.
      finnerave=(finnerave*(nstepsave-1) + float(ninner))/nstepsave 
c Use an averaging process to calculate rhoinf (=riave)
      riave=(riave*(nstepsave-1) + riest)/nstepsave 
c      if(myid.eq.0) write(*,'(a,2f9.2,a,i6,f8.1,f8.1)')
c     $     'riest,riave',riest,riave,
c     $     '  ninner,finave,adj',ninner,finnerave,
c     $     finnerave*colnwt/(4.*3.1415926*dt*(1.+Ti)*r(NRFULL))
c*******
      rhoinf=riave
      end