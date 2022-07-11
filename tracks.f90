      real*8 bin(100000),sum,itops
!      integer bin(100000),nleng(2),ilft, irght, leng,leftend,rightend,Reason,sum,lpos
      integer nleng(2),ilft, irght, leng,leftend,rightend,Reason,lpos
      character(len=6) :: unk,rchr
      character(len=5) :: unk2,rchr2
      character(len=44) :: siq!for hmm annos
      character(len=62) :: arg
      character(len=62) :: path(2)
      logical :: file_exists
      inot=0
      itops=0
      iread=0
      rchr="chr1" !starts on chr1
      do i=1,iargc()
         if(i.lt.3)then
         call getarg(i, arg)
            path(i)=arg
         else
         call getarg(i, arg)
            read(arg,*)nleng(i-2)
         endif
      enddo
      do k=1,2 !files loop
      inquire(file=path(k),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(12,file=path(k))      
      else
         write(*,*) 'your first file or path is incorrect'
         stop
      endif

      bin=0d0
      leftend=0
      rightend=0

      if(k.eq.1)open(88,file='IP.data')
      if(k.eq.2)open(88,file='IN.data')
      if(k.eq.2)open(89,file='INave.data')
12345 continue
      read(12,*,IOSTAT=Reason) unk, ilft, irght, leng      
      if(Reason.gt.0)then
         write(*,*) 'there was an error in input file ', path(k)
         stop
      elseif(Reason.eq.0)then 
23456    continue
!only work the given chr by using this line
!      if(unk /= "chr1")go to 54321 

      if(SCAN(unk(5:6), "_").eq.0)then

         if(ilft.gt.rightend.and.unk == rchr)then
            !write out the current bin of data
            if(itops.gt.1*0)then !nonempty
               lpos=leftend
               ave=0d0
               count=0d0
               do i=1,rightend-leftend,nleng(k)
                  sum=0
                  iend=min(rightend-leftend,i+nleng(k)-1)!double test
                  idub=0
                  do j=i,iend
                     lpos=lpos+1
                     idub=idub+1
                     sum=sum+bin(j)
                  enddo
!                  write(88,*) unk, lpos-nleng(k)/2, dble(sum)/dble(nleng(k))
                  write(88,*) unk, lpos-idub,lpos-1, dble(sum)!/dble(idub)
                  ave=ave+dble(sum)/dble(idub)
                  count=count+1d0
               enddo
               if(k.eq.2)then
                  write(89,*) unk, leftend, rightend, ave/count
               endif
            endif
            bin=0
            itops=0
            !set new bins
            leftend=ilft
            rightend=ilft+leng!same as irght sometimes
            do i=1,rightend-leftend
               bin(i)=bin(i)+1d0/leng
               itops=max(itops,bin(i))
            enddo
            go to 12345
         elseif(ilft.le.rightend.and.unk == rchr)then
            iindicate=0
            rightend=max(rightend,ilft+leng)!new right end
!            leftend = 1 in position so ilft-leftend+1 is start location
!            if(1+ilft-leftend.lt.1)then
!               write(*,*) unk, ilft, leftend, "ji", rchr
!               stop
!            endif
            if(1+ilft-leftend.lt.100000.and.rightend-leftend.le.100000)then
            do i=min(100000,1+ilft-leftend),min(100000,1+ilft-leftend+leng)!rightend-leftend
               bin(i)=bin(i)+1d0/leng
               itops=max(itops,bin(i))
            enddo   
            go to 12345
            else!the bounds of bin will be exceeded so reset bins now-can happen on inputs
               !final update and dump it out
               do i=min(100000,1+ilft-leftend),min(100000,1+ilft-leftend+leng)!rightend-leftend
                  bin(i)=bin(i)+1d0/leng
                  itops=max(itops,bin(i))
               enddo

            if(itops.gt.1*0)then!not likely needed
               lpos=leftend
               ave=0d0
               count=0d0
               do i=1,ilft,nleng(k)!rightend-leftend,nleng(k)
                  sum=0
                  idub=0
                  iend=min(ilft-leftend,i+nleng(k)-1)!double test
                  do j=min(i,100000),min(iend,100000)!double test
                     lpos=lpos+1
                     idub=idub+1
                     sum=sum+bin(j)
                  enddo
!                  write(88,*) unk, lpos-nleng(k)/2, dble(sum)/dble(nleng(k))
                  if(idub.gt.1)then
                  write(88,*) unk, lpos-idub,lpos-1, dble(sum)!/dble(idub)
                  ave=ave+dble(sum)/dble(idub)
                  count=count+1d0
                  endif
               enddo
               iindicate=1
               if(k.eq.2)then
                  write(89,*) unk, leftend, rightend, ave/count
               endif

            endif
            if(iindicate.eq.0)then
               bin=0
            itops=0
            !set new bins
            leftend=0
            rightend=0
            else!ilft should hold the last fragment read and 
! ----------------- WORKING HERE TO SHIFT BIN correctly
               itops=0!clear this
               j=0
               do i=1+ilft-leftend,100000
                  j=j+1
                  bin(j)=bin(i)
                  itops=max(itops,bin(j))                  
               enddo!anything outside should have been zero anyway
               leftend=ilft
               rightend=irght!rightend!same one
            endif
            rchr=unk
            go to 12345!23456
            endif!protect bounds of bin
         endif
         if(unk /= rchr)then
            write(*,*) unk, rchr, k, itops
            if(itops.gt.1*0)then
               lpos=leftend
               ave=0d0
               count=0d0
               do i=1,rightend-leftend,nleng(k)
                  sum=0
                  idub=0
                  do j=i,min(rightend-leftend,i+nleng(k)-1)!double test
                     lpos=lpos+1
                     idub=idub+1
                     sum=sum+bin(j)
                  enddo
                  write(88,*) rchr, lpos-idub,lpos-1, dble(sum)!/dble(idub)
!                  write(88,*) unk, lpos-nleng(k)/2, dble(sum)/dble(nleng(k))
                  ave=ave+dble(sum)/dble(idub)
                  count=count+1d0
               enddo
               if(k.eq.2)then
                  write(89,*) rchr, leftend, rightend, ave/count
               endif
            endif
            bin=0
            itops=0
            !set new bins
            leftend=0
            rightend=0
            rchr=unk
            go to 23456
         endif
         else
            go to 12345
         endif!the _ screen
      endif
54321 continue!jumpout landing
      close(12)
      close(88)
      enddo!k files loop

    end program
