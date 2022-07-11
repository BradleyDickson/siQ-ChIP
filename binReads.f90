      real*8 isiq,iscor,area
      integer ilft, irght,ilft2,irght2,Reason,ReasonA,counts
!      integer ilft, irght, iscore,ilft2,irght2,Reason,ReasonA,isiq
      character(len=7) :: unk,rchr
      character(len=7) :: unk2,rchr2
      character(len=44) :: siq!for hmm annos
      character(len=62) :: arg
      character(len=62) :: path(2)
      logical :: file_exists
      inot=0
      iwrote=0
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
      open(81,file='matches.coords')
      open(82,file='notmatches.coords')
12345 continue
      counts=0
      area=0d0
32325          continue
               read(12,*,IOSTAT=Reason) unk, ilft, irght, iscor
               if(Reason.eq.0.and.index(unk,'_').gt.0)go to 32325

!      read(12,*,IOSTAT=Reason) unk, ilft, irght, iscor
!      read(12,*,IOSTAT=ReasonA) unk2, ilft, irght, siq!need be isiq for most !last read will get lost on updates below, is ok     
      irght=irght-1
      if(Reason.gt.0)then
         write(*,*) 'there was an error in input file ', path(1)
      elseif(Reason.eq.0)then 
         rchr=unk
12344    continue
         read(13,*,IOSTAT=ReasonA) unk2, ilft2, irght2, siq!need be isiq for most !last read will get lost on updates below, is ok
!         read(13,*,IOSTAT=ReasonA) unk2, ilft2, irght2, iscor
         irght2=irght2-1!is ok eddie?
         if(ReasonA.gt.0)then
            write(*,*) 'there was an error in input file ', path(2)
         elseif(ReasonA.eq.0)then
            rchr2=unk2
11223       continue
!            if(unk2 /= unk)then
!               write(*,*) unk, unk2, ilft, irght, ilft2, irght2
!               stop
!            endif
!            if(ilft.le.irght2.and.ilft2.le.irght.and. unk2 == unk.and.iscor.eq.1)then!.gt.1 for iscor was here <---
            if(ilft.le.irght2.and.ilft2.le.irght.and. unk2 == unk)then!.gt.1 for iscor was here <---
!               if(siq.gt.1)write(*,*) unk2, ilft2, irght2, int(siq)!conditional not for general use
               write(81,*) unk,ilft,irght, iscor, siq!ilft, irght, iscor!isiq, iscor !write matches
               counts=counts+1 !* (irght-ilft) !you could go on length here but change makeFracs.sh also
               area=area+iscor
32323          continue
               read(12,*,IOSTAT=Reason) unk, ilft, irght, iscor
               if(Reason.eq.0.and.index(unk,'_').gt.0)go to 32323
               if(Reason.eq.0)go to 11223
!               go to 12344
            elseif(unk2 == unk.and.ilft.gt.irght2)then
               !didnt match so far
!               write(82,*) unk2, ilft2, irght2, isiq, iscor
               write(90,*) unk, ilft2, irght2, counts, siq
!               write(90,*) unk, ilft2, irght2, area, siq
               counts=0!start over, go get new anno
               area=0d0
               go to 12344!hasnt matched but need a new comp line
!            elseif(unk2 == unk.and.ilft2.gt.irght.or.iscor.eq.1)then!what for iscor?
            elseif(unk2 == unk.and.ilft2.gt.irght)then!what for iscor?
               !gave up on this interval --- no --- rather, keep processing
!               write(90,*) unk, ilft, irght, counts, siq
!               counts=0
32324          continue
               read(12,*,IOSTAT=Reason) unk, ilft, irght, iscor
               if(Reason.eq.0.and.index(unk,'_').gt.0)go to 32324
!               read(12,*,IOSTAT=ReasonA) unk2, ilft, irght, siq!need be isiq for most !last read will get lost on updates below, is ok     
               if(Reason.eq.0)go to 11223
            elseif(unk2 /= unk)then
               if(ilft.gt.irght2)then
               !gave up on this interval
               write(90,*) unk, ilft, irght, counts, siq
!               write(90,*) unk, ilft, irght, area, siq
               counts=0
               area=0d0
                  go to 12345
               endif
!               write(11,*) unk2, ilft2, irght2, int(siq)
               write(82,*) unk2, ilft2, irght2, isiq, iscor!testing for lost
               go to 12344!get new comp
            endif
         endif
!         go to 12345
      endif
      close(12)
      close(13)
    end program
