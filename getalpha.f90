      real*8 par(24),parm !all measurements
      real*8 fb,fi,fil,fbl,vr,concin,rhorho,emperical
      real*8 ct,ampli,concip,reads,cexpectIN,cexpectIP 
      real*8 depths(2)
      integer Reason
      character(len=62) :: arg
      character(len=62) :: path(2)
      logical :: file_exists
      do i=1,iargc()
         call getarg(i, arg)
         if(i.eq.1)then
         path(i)=arg
         else
         read(arg,*)depths(i-1)
         endif
      enddo

      inquire(file=path(1),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(33,file=path(1))      
      else
         write(*,*) 'your first file or path is incorrect'
         stop
      endif
      !params.in
      do i=1,6!24
         read(33,*,IOSTAT=Reason) parm
         if(Reason.eq.0)then
            par(i)=parm
         endif            
      enddo
      close(33)
      vr=par(1)/(par(2)-par(1))
      emperical=vr*par(4)/par(3)*depths(1)/depths(2) * par(6)/par(5) !this last term is the lengths
      write(*,*) emperical
      stop
      fb=par(2)/par(1)
      fi=par(4)/par(3)
      fbl=par(7)*par(8)/par(5)/par(6)
      fil=par(11)*par(12)/par(9)/par(10)
      vr=par(13)/(par(14)-par(13))
      emperical = vr*par(1)/par(3)*depths(1)/depths(2)
      ct=par(16) !assumed the same in input and IP
      concin=par(9)
      concip=par(5)
      lengthin=par(24)
      lengthip=par(19)
      readin=1d0!unity
      readip=1d0
! your ct is built in this estimated library conc. 
! 10 nano grams apli ct times: (so we hardcoded for 10ng)
!remove hardcode
      cexpectIP= &
      par(15)*1e-09/(par(19)*660d0) *2d0**ct/(par(17)*1e-06)*1e+09
!you would uncomment this stuff if you had ng/uL rather than nM
      actualIP=par(18)!*1e-09*par(17)/(660d0*par(19))/(par(17)*1e-06)*1e+09
      cexpectIN= &
      par(20)*1e-09/(par(24)*660d0) *2d0**ct/(par(22)*1e-06)*1e+09
!as above but for input      
      actualIN=par(23)!*1e-09*par(22)/(660d0*par(24))/(par(22)*1e-06)*1e+09
!      write(*,*) vr*fi/fb
!      write(*,*) fil/fbl

!      write(*,*) par(20), actualIN/cexpectIN, " rho"
!      write(*,*) par(15), actualIP/cexpectIP, "rho"
!      write(*,*) "input ", fi*actualIN/cexpectIN*fil*par(13)
!      write(*,*) "ip ", fb*actualIP/cexpectIP*fbl*(par(14)-par(13))
!      write(*,*) "junks ", &
!      (fi*actualIN/cexpectIN*fil*par(13))/(fb*actualIP/cexpectIP*fbl*(par(14)-par(13)))
!      write(*,*) "perfect 50/100 ", &
!      .5d0*(fi*actualIN/cexpectIN*fil*par(13))/(fb*actualIP/cexpectIP*fbl*(par(14)-par(13)))
!      write(*,*) "at 30/100 ", &
!      .3d0*(fi*actualIN/cexpectIN*fil*par(13))/(fb*actualIP/cexpectIP*fbl*(par(14)-par(13)))
!      write(*,*) "at 12.5/100 ", &
!      .125d0*(fi*actualIN/cexpectIN*fil*par(13))/(fb*actualIP/cexpectIP*fbl*(par(14)-par(13)))

!      write(*,*) vr*fi*fil/fb/fbl , actualIN/cexpectIN/(actualIP/cexpectIP)
!vr=par(13)/(par(14)-par(13))
!      write(*,*) "fil=",fil, "fi=",fi
!      write(*,*) "fbl=",fbl, "fb=",fb 
!      write(*,*) "ratio F-l=",fil/fbl
!      write(*,*) "ratio F=",fi/fb
!here is a useless 2^ct for no reason
!      ampliin = 2d0**ct/((cexpectIN/actualIN)) !assumed in nM
!      ampliip = 2d0**ct/((cexpectIP/actualIP)) !nM units!!!
!with all those definitions alpha is (factr):
!      factr= readin*fi*fil*ampliin*vr/(fb*fbl*ampliip*readip)
!      write(*,*) factr

! it is possible to write alpha as follows, though it is not instructive:
!      write(*,*) &
!      (par(13)/(par(14)-par(13)))* &
!      (par(4)/par(3))*(par(11)*par(12)/par(9)/par(10))/ &
!      ((par(2)/par(1))*(par(7)*par(8)/par(5)/par(6))) * &
!      (par(15)/par(20))*(par(24)/par(19))*(par(22)/par(17)) &
!        * (par(23)/par(18)), emperical
      write(*,*) emperical
!      stop
      end program
