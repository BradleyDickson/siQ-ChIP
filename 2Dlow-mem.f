      real*8 inputibin(100),ipibin(100),bigrat(100)
      real*8 c(1000),count(100)
      real*8 par(24) !all measurements
      real*8 fb,fi,fil,fbl,vr,concin
      real*8 ct,ampli,concip,reads,cexpectIN,cexpectIP
      integer ish,ileft,iright,ipred,iplines,inplines,inred
      integer ibigstrt,ibigend,nbres,lengthin,lengthip
      character(len=5) :: unk
      open(15,file="flinesLOCN")       
      read(15,*) nlines, min, max !assume 1 to max for domain      
      
      inplines=nlines
      maxl=1000 !may or may not be robust but this is longest length now
      nbinl1=int(dble(maxl)/dble(ishl))!for xlink it will be larger.
      read(15,*) nlines, min, max !assume 1 to max for domain      
      iplines=nlines
      close(15)

      thresh=0d0
      count=0d0
c      open(33,file='fractions')
c      read(33,*) fi, fb, fil, fbl, vr, ct, concin, concip, lengthin, 
c     .     lengthip
c      close(33)

      !params.in
      open(33,file="params.in")
      do i=1,24
         read(33,*) par(i)
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

      cexpectIN=1e-09*10d0*2d0**ct/(dble(lengthin)*660d0)/(20d0*1e-06)
      cexpectIP=1e-09*10d0*2d0**ct/(dble(lengthip)*660d0)/(20d0*1e-06)
      cexpectIN=1000d0*cexpectIN*1e+06 !convert to nM, [library] is in nM
      cexpectIP=1000d0*cexpectIP*1e+06 !convert to nM

!check it out if you want to:
c      write(*,*) cexpectIN, cexpectIP
c      write(*,*) concin/cexpectIN, concip/cexpectIP
c      write(*,*) (concin/cexpectIN)/(concip/cexpectIP)
c      stop

      ampliin = 2d0**ct/((cexpectIN/concin)) !assumed in nM
      ampliip = 2d0**ct/((cexpectIP/concip)) !nM units!!!

      factr= readin*fi*fil*ampliin*vr/(fb*fbl*ampliip*readip)
c      write(*,*) factr
c      stop

      ipred=0
      inred=0
      c=0d0

      open(21,file='resi')
      read(21,*) ish, ishl, nbres
      close(21)
      inputibin=0d0!initialize
      ipibin=0d0
!debug file list
c      open(22,file='chr2.2d')
c      open(33,file='chr2.2dLR')
c      open(12,file="ip.chr2") !FILENAME checks here
c      open(13,file="in.chr2") !FILENAME checks here
!production file list
      open(44,file='chrLOCN.ce')
      open(22,file='chrLOCN.2d')
      open(33,file='chrLOCN.2dLR')
      open(15,file="flinesLOCN")       
      open(12,file="ip.chrLOCN") !FILENAME checks here
      open(13,file="in.chrLOCN") !FILENAME checks here

      nbinl2=int(dble(maxl)/dble(ishl))!for xlink it will be larger.
      nbinl=nbinl2
      if(nbinl.lt.nbinl1)nbinl=nbinl1

      !could use a sanity check on nbinl here. 
      if(nbinl.gt.100)then
         write(*,*) "nbin problem"
         stop
      endif
      !get the first entry and start position of bins
      read(12,*) unk, ileft, iright, reads
      ipred=ipred+1!a line was red

      ibigstrt=ileft
      ibigend=ibigstrt+nbres
      bigrat=0d0

!if ibinstart is changed should ibigstrt have the chance to change?
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 1414 continue!come back here sometimes while working the file

      !it is impossible to know if ibig should be updated, so check
      !so some files can hit dump here and at another fork
      if(ibigend.lt.ileft)then!needs update
            do j=1,nbinl           
               if(count(j).gt.0)then
               write(33,*) unk, ibigstrt, (j-0.5)*ishl, 
     .              factr*bigrat(j)/dble(nbres)!, bigrat(j)/dble(nbres)
               else!don't NaN
               write(33,*) unk, ibigstrt, (j-0.5)*ishl, 
     .              0d0!, 0d0
               endif
            enddo!

            bigrat=0d0
            count=0d0
            do j=1,nbinl
               if(inputibin(j).gt.0)then
                  bigrat(j)=bigrat(j)+ipibin(j)/inputibin(j)
                  count(j)=count(j)+1d0 !started over now at this bin
               else !no data
                  bigrat(j)=bigrat(j)+0d0
                  count(j)=count(j)+1d0
               endif
            enddo


            idif=int(dble(ibinstart-ibigend)/dble(nbres))+1 !how many intervals we are looking for

            do j=1,idif
            write(44,*) unk, ibigstrt+(j-1)*nbres, ibigstrt+j*nbres
     .              , factr*c(j)/dble(nbres)!, c(j)/dble(nbres) !this column is unscaled
            enddo
            do k=idif+1,1000!shift to next windows
               c(k-(idif))=c(k)
            enddo
            do k=1000-idif,1000!
            c(k)=0d0
            enddo

      ibigstrt=ileft !same as ileft here
      ibigend=ibigstrt+nbres 

      endif
      ibinstart=ileft !
      ibinend= ibinstart+ish!ish will give global resolution i guess.

      ileg=int((reads)/dble(ishl))+1 !no zero
      ipibin(ileg)=ipibin(ileg)+1d0!this fragment started in this bin
 1313 continue!loop reading the file here, the previous read is done
      read(12,*) unk, ileft, iright, reads
      ipred=ipred+1!a line was red
      if(ileft.gt.ibinend.and.inred.lt.inplines)then!ok, there is no more data for ibin since file is sorted
         !right here need to do the same work on the input file
         !for the reads in input that are in this bin, but not others.
 3131    continue

         read(13,*) unk, inleft, inright, reads!reuse of reads variable
         inred=inred+1          !a line was red

         if(inleft.ge.ibinstart.and.inleft.le.ibinend)then
            ileg=int((reads)/dble(ishl))+1 !no zero
            inputibin(ileg)=inputibin(ileg)+1d0 !this fragment started in this bin
            if(inred.lt.inplines-1)then
               go to 3131
            endif
         elseif(inleft.le.ibinend)then!this is droping the first outside read
            if(inred.lt.inplines-1)then
               go to 3131
            endif
         endif
         !stop the input work here--------------------------------------
         do j=1,nbinl
            if(inputibin(j).gt.0)then!you can screen here if you want to, and catch NaN
            write(22,*) unk, ibinstart, (j-0.5)*ishl, 
     .           factr*ipibin(j)/inputibin(j), ipibin(j)/inputibin(j)
            else
            write(22,*) unk, ibinstart, (j-0.5)*ishl, 
     .           0d0, 0d0
            endif
         enddo
c         !project to 1D here for browser gazing
         do j=1,nbinl
            icend=int(dble((ibinstart+j*ishl)-ibigstrt)/dble(nbres))+1 !hit all c() that get hit
            if(inputibin(j).gt.0)then!you can screen here if you want to, and catch NaN
               if(factr*ipibin(j)/inputibin(j).gt.thresh)then !pass filter
                  c(icend)=c(icend)+ipibin(j)/inputibin(j) !hit this bin
               endif
            endif
         enddo
         !collect larger bin averages of ratio here
         !bin should be the current little bin plus 10k or whatever
         !if the current little bin was just created and not in the current big bin
         if(ibinstart.ge.ibigstrt.and.ibinstart.le.ibigend)then
            do j=1,nbinl
               if(inputibin(j).gt.0)then
                  if(factr*ipibin(j)/inputibin(j).gt.thresh)then !pass filter
                  bigrat(j)=bigrat(j)+ipibin(j)/inputibin(j)
                  count(j)=count(j)+1d0 !number of little intervals that go in big one
                  endif
               endif
            enddo

         elseif(ibinstart.gt.ibigend)then!new bin, no weight on the splits here
            do j=1,nbinl           
               if(count(j).gt.0)then
               write(33,*) unk, ibigstrt, (j-0.5)*ishl, 
     .              factr*bigrat(j)/dble(nbres)!, bigrat(j)/dble(nbres)
               else!don't NaN
               write(33,*) unk, ibigstrt, (j-0.5)*ishl, 
     .              0d0!, 0d0
               endif
            enddo!

            bigrat=0d0
            count=0d0
            do j=1,nbinl
               if(inputibin(j).gt.0)then
                  bigrat(j)=bigrat(j)+ipibin(j)/inputibin(j)
                  count(j)=count(j)+1d0 !started over now at this bin
               else !no data
                  bigrat(j)=bigrat(j)+0d0
                  count(j)=count(j)+1d0
               endif
            enddo


            idif=int(dble(ibinstart-ibigend)/dble(nbres))+1 !how many intervals we are looking for

            do j=1,idif
            write(44,*) unk, ibigstrt+(j-1)*nbres, ibigstrt+j*nbres
     .              , factr*c(j)/dble(nbres)!, c(j)/dble(nbres) !remove 
            enddo
            do k=idif+1,1000!shift to next windows
               c(k-(idif))=c(k)
            enddo
            do k=1000-idif,1000!
            c(k)=0d0
            enddo

            ibigstrt=ibinstart
            ibigend=ibigstrt+nbres

         endif

         inputibin=0d0!initialize
         ipibin=0d0
         if(ipred.lt.iplines-1)then
         go to 1414 !do this if something
         endif
      else
         ileg=int((reads)/dble(ishl))+1 !no zero
         ipibin(ileg)=ipibin(ileg)+1d0 !this fragment started in this bin
         if(ipred.lt.iplines-1)then
         go to 1313 !do this if something
         endif
      endif


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      end
            
