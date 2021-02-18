      integer bin(100000)
      real*8 iphits,inhits
      integer Reason,Reason2,ilft,irght,ilft2,irght2
      character(len=5) :: unk,rchr !should have been filtered to chrxx by now
      character(len=5) :: unk2,rchr2
      character(len=44) :: siq!for hmm annos
      character(len=62) :: arg
      character(len=62) :: path(3)
      logical :: file_exists

      inot=0
      iread=0
      rchr="chr1" !starts on chr1
      do i=1,iargc()
         call getarg(i, arg)
         path(i)=arg
      enddo
      inquire(file=path(1),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(12,file=path(1))      
      else
         write(*,*) 'your first file or path is incorrect'
         stop
      endif
      inquire(file=path(2),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(13,file=path(2))      
      else
         write(*,*) 'your second file or path is incorrect'
         stop
      endif
      call getarg(3,arg)
      read(arg,*)factr!this is alpha

      open(88,file='mergedSIQ.data')
      !match intervals as much as possible      
12121 continue
      read(12,*,IOSTAT=Reason) unk, ilft, irght, iphits
      if(Reason.gt.0)then
         write(*,*) 'there was an error in input file ', path(1)
         stop
      elseif(Reason.eq.0)then 
12344    continue
         read(13,*,IOSTAT=Reason2) unk2, ilft2, irght2, inhits
         if(Reason2.gt.0)then
            write(*,*) 'there was an error in input file ', path(2)
            stop
         elseif(Reason2.eq.0)then
12345       continue
            if(unk == unk2.and.ilft.le.irght2.and.ilft2.le.irght)then!intersect
               if(inhits.lt.1)inhits=oin!no boom
               if(inhits.gt.0d0)then!dont smooth input
!               if(inhits.gt.14d0)then!7d0 is 100m-depth estimate
               write(88,*) unk, ilft, irght, factr*iphits/inhits
!               else   !these lines are for smoothing input
!               write(88,*) unk, ilft, irght, factr*iphits/7d0
               endif
               !get a new IP line and return to check
               read(12,*,IOSTAT=Reason) unk, ilft, irght, iphits
               if(Reason.eq.0)go to 12345!check start
            elseif(unk2 == unk.and.ilft.gt.irght2)then
               oin=inhits!save
               go to 12344!hasnt matched but need a new comp line
            elseif(unk2 == unk.and.ilft2.gt.irght)then!get new line
               read(12,*,IOSTAT=Reason) unk, ilft, irght, iphits
               if(Reason.eq.0)go to 12345!check start
            elseif(unk2 /= unk)then
               if(ilft.gt.irght2)then!because 13- went to new chr
                  go to 12121
               endif
               oin=inhits!save
               go to 12344!get new comp
            endif
         endif!close 13 read
      endif!close 12 read
!      write(*,*) "i stop now at"
!      write(*,*) unk, ilft, irght, iphits
!      write(*,*) unk2, ilft2, irght2, inhits      
      close(88)
      close(12)
      close(13)
      end program
