
c************************************************************************

      Subroutine fitrange(xmin,xmax,ntics,nxfac,xfac,xtic,xt1st,xtlast)
c
c  To fit a suitable axis range for reasonable scales.
c  Inputs:
c	xmin, xmax: range to be fitted.
c	ntics: (maximum) number of divisions (tics) to fit to it.
c  Outputs:
c	nxfac: power of ten by which the range is scaled.
c	xfac: 10**nxfac. World-value=xfac*axis-label.
c	xtic: Tic-spacing in world units.
c       xt1st: The integer multiple of xtic closest to xmin 
c             lying outside the range (xmin,xmax).
c       xtlast: The integer multiple of xtic closest to xmax
c             lying outside the range (xmin,xmax).
      real span,nsfac,sfac

      span=xmax-xmin
      nxfac=nint(log10(max(abs(xmin),abs(xmax)))-0.4999999)
      xfac=10.**nxfac
      if(ntics.le.0)then
	 write(*,'('' ntics<=0'')')
	 return
      endif
      xtic=span/ntics
      nsfac=nint(log10(0.099999*abs(xtic))+0.500001)
      sfac=10.**nsfac
      xtic=abs(xtic)/sfac
      if(xtic.lt.1.)then
	 write(*,'('' Fitrange error 1. xtic='',f16.7)')xtic
      elseif(xtic.le.2.)then
	 xtic=2.
      elseif(xtic.le.3.)then
	 xtic=4.
      elseif(xtic.le.5.)then
	 xtic=5.
      elseif(xtic.le.10.0001)then
	 xtic=10.
      else
	 write(*,'('' Fitrange error NAN. Range:'',2g10.4)'),xmin,xmax
         xtic=1.
         nxfac=0.
         sfac=1.
         xfac=1.
      endif
      xtic=xtic*sfac
      xtic=sign(xtic,span)
      xt1st=xtic*anint(xmin/xtic-0.49999)
      xtlast=xtic*anint(xmax/xtic+0.49999)
      return
      end
c********************************************************************
c      program testfit
c    1 write(*,'('' Enter xmin,xmax,ntics'')')
c      read(*,*)xmin,xmax,ntics
c      call fitrange(xmin,xmax,ntics,nxfac,xfac,xtic)
c      write(*,'('' nxfac='',i5,'' xfac='',e10.1,'' xtic='',f10.4)')
c     $	   nxfac,xfac,xtic
c      goto 1
c      end

