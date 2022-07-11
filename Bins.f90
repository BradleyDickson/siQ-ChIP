      real*8 bins(100,1500)
      real*8 points(3,200)
      real*8 di, sum, dc,rsp,frec,runk
      integer AllocateStatus,Reason,ijunk,ileft,iright,nlines
      integer nfre,nresp,npoi
      character(len=5) :: unk
      character(len=5) :: unk2
      character(len=132) :: arg
      character(len=132) :: path(2)
      character(len=132) :: file_name
      character(len=32) :: names(2)
      logical :: file_exists
      bins=0d0
      points=0d0
      nfre=70
      nresp=700
      npoi=0
      do i=1,iargc()
         call getarg(i, arg)
         if(i.lt.3)then
            path(i)=arg
         else
            names(i-2)=arg
         endif
      enddo

      inquire(file=path(1),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(12,file=path(1))      
         file_name=trim(path(1)) // '.histogram'
      else
         write(*,*) 'your first file or path is incorrect'
         stop
      endif

      nlines=0
12345 continue
      read(12,*,IOSTAT=Reason) ijunk, unk, ileft, iright, frec, runk, rsp, runk, runk, runk, runk
!      reads=ruds
      if(Reason.gt.0)then
         write(*,*) 'there was an error in input file ', path(1)
      elseif(Reason.eq.0)then 
         nlines=nlines+1
         if(frec.lt.1d0.and.rsp.lt.100d0)then
         iat=int(frec/(1d0/dble(nfre)))+1
         jat=int(rsp/(100d0/dble(nresp)))+1
         
         bins(iat,jat)=bins(iat,jat)+1d0
         endif
!         points(1,nlines)=frec
!         points(2,nlines)=rsp
         go to 12345
      endif
      open(89,file=trim(file_name))      
      dx=1d0/dble(nfre)
      dy=100d0/dble(nresp)
      do i=1,nfre
         do j=1,nresp
            write(89,*) (i+0.5d0)*dx, (j+0.5d0)*dy, bins(i,j)
         enddo
         write(89,*)
      enddo
      close(89)
      open(89,file="tops.data")      
      nk=1
      do i=1+nk,nfre-nk
         do j=1+nk,nresp-nk
            dxl=max(0d0,bins(i-nk,j)-bins(i,j)+0)
            dxr=max(0d0,bins(i+nk,j)-bins(i,j)+0)
            dyl=max(0d0,bins(i,j-nk)-bins(i,j)+0)
            dyr=max(0d0,bins(i,j+nk)-bins(i,j)+0)
!            if(dxl+dxr+dyl+dyr.eq.0d0.and.bins(i,j).gt.25d0)then
!               nk2=1
!               dxl=max(0d0,bins(i-nk2,j)-bins(i,j))
!               dxr=max(0d0,bins(i+nk2,j)-bins(i,j))
!               dyl=max(0d0,bins(i,j-nk2)-bins(i,j))
!               dyr=max(0d0,bins(i,j+nk2)-bins(i,j))
               if(dxl+dxr+dyl+dyr.eq.0d0.and.bins(i,j).gt.25d0.and.npoi.lt.200)then
                  npoi=npoi+1
                  points(1,npoi)=(i+0.5d0)*dx
                  points(2,npoi)=(j+0.5d0)*dy
                  points(3,npoi)=bins(i,j)
!                  write(89,*) (i+0.5d0)*dx, (j+0.5d0)*dy, bins(i,j)
               endif
!            endif
         enddo
      enddo
      do i=1,npoi-1
         pstrt=points(3,i)
         iat=i
         do j=i+1,npoi
            di=sqrt((points(1,i)-points(1,j))**2+(points(2,i)/10d0-points(2,j)/10d0)**2)
            if(di.lt.0.5d0)then
               if(points(3,j).gt.pstrt)then!i win
                  pstrt=points(3,j)
                  iat=j
               endif
            endif
         enddo
         write(89,*) (points(k,iat),k=1,3)
      enddo
      close(89)
      end program
