      real*8 par(24),parm !all measurements
      real*8 fb,fi,fil,fbl,vr,concin
      real*8 ct,ampli,concip,reads,cexpectIN,cexpectIP 
      integer Reason
      character(len=62) :: arg
      character(len=62) :: path(2)
      logical :: file_exists
      do i=1,iargc()
         call getarg(i, arg)
         path(i)=arg
      enddo
      inquire(file=path(1),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(33,file=path(1))      
      else
         write(*,*) 'your first file or path is incorrect'
         stop
      endif
      !params.in
      do i=1,24
         read(33,*,IOSTAT=Reason) parm
         if(Reason.eq.0)then
            par(i)=parm
         endif            
      enddo
      close(33)

      fb=par(2)/par(1)
      fi=par(4)/par(3)
      fbl=par(7)*par(8)/par(5)/par(6)
      fil=par(11)*par(12)/par(9)/par(10)
      vr=par(13)/(par(14)-par(13))
      ct=par(16)
      concin=par(9)
      concip=par(5)
      lengthin=par(24)
      lengthip=par(19)
      readin=1d0!unity
      readip=1d0
      cexpectIN=1e-09*par(20)*2d0**ct &
          /(dble(lengthin)*660d0)/(par(17)*1e-06)
      cexpectIP=1e-09*par(15)*2d0**ct &
          /(dble(lengthip)*660d0)/(par(17)*1e-06)
      cexpectIP= &
      par(15)*1e-09/(par(19)*660d0) *2d0**ct/(par(17)*1e-06)*1e+09
      actualIP=par(18)*1e-09*par(17)/(660d0*par(19))/(par(17)*1e-06)*1e+09
      cexpectIN= &
      par(20)*1e-09/(par(24)*660d0) *2d0**ct/(par(22)*1e-06)*1e+09
      actualIN=par(23)*1e-09*par(22)/(660d0*par(24))/(par(22)*1e-06)*1e+09
!      write(*,*) "expected and actual in nM"
!      write(*,*) cexpectIP
!      write(*,*) actualIP/cexpectIP
!      write(*,*) cexpectIN
!      write(*,*) actualIN
!      write(*,*) actualIN/cexpectIN
      ampliin = 2d0**ct/((cexpectIN/actualIN)) !assumed in nM
      ampliip = 2d0**ct/((cexpectIP/actualIP)) !nM units!!!
      factr= readin*fi*fil*ampliin*vr/(fb*fbl*ampliip*readip)
      write(*,*) factr
!      stop
      end program
