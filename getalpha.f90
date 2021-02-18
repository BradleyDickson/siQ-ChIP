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
! your ct is built in this estimated library conc. 
! 10 nano grams apli ct times: (so we hardcoded for 10ng)
!remove hardcode
      cexpectIN=1e-09*par(20)*2d0**ct &
          /(dble(lengthin)*660d0)/(20d0*1e-06)
      cexpectIP=1e-09*par(15)*2d0**ct &
          /(dble(lengthip)*660d0)/(20d0*1e-06)
!hardcoded to 10ng
!      cexpectIN=1e-09*10d0*2d0**ct/(dble(lengthin)*660d0)/(20d0*1e-06)
!      cexpectIP=1e-09*10d0*2d0**ct/(dble(lengthip)*660d0)/(20d0*1e-06)
      cexpectIN=1000d0*cexpectIN*1e+06 !convert to nM, [library] is in nM
      cexpectIP=1000d0*cexpectIP*1e+06 !convert to nM
!check it out if you want to:
!      write(*,*) cexpectIN, cexpectIP
!      write(*,*) concin/cexpectIN, concip/cexpectIP
!      write(*,*) (concin/cexpectIN)/(concip/cexpectIP)
!      stop
      ampliin = 2d0**ct/((cexpectIN/concin)) !assumed in nM
      ampliip = 2d0**ct/((cexpectIP/concip)) !nM units!!!
      factr= readin*fi*fil*ampliin*vr/(fb*fbl*ampliip*readip)
      write(*,*) factr
!      stop
      end program
