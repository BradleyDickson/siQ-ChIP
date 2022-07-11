      real*8 reads,axe,edge,thres,reads2,ruds
      real*8 tracks(100000),tracks2(100000),del,el,dfwin
      real*8 a1,a2,di,s,df,df0,df1,ddf,axm,axm2,swin
      real*8 rpos(100000),rpos2(100000)
      real*8 histo(100),sum,ameans,bwidth,ameans2,sigmas
      integer iedge(5000,2),ipos(100000),ileft,iright,istart,iend
      integer iedge2(5000,2),ipos2(100000),ileft2,iright2,ipeaks,npeaks
      integer AllocateStatus,Reason,irsided,ilbig,irbig,ink
      character(len=5) :: unk,chraim
      character(len=5) :: unk2
      character(len=132) :: arg
      character(len=132) :: path(2)
      character(len=32) :: names(2)
      logical :: file_exists
      !bwidth should be passed in
      !read it from resi file - prob better
!      open(12,file='resi') !this file no longer used by siq
!      read(12,*) ink, ink, bwidth
!      close(12)
      bwidth=100 !this is now hardset in siq scripts
      ean1=0d0
      ean2=0d0
      histo=0d0
      axm=0d0
      ameans=0d0
      ameans2=0d0
      do i=1,iargc()
         call getarg(i, arg)
         if(i.lt.3)then
            path(i)=arg
         elseif(i.gt.2.and.i.lt.5)then
            names(i-2)=arg
         elseif(i.eq.5)then
            read(arg,*)sigmas
         endif
      enddo


      inquire(file=path(1),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(12,file=path(1))      
      else
         write(*,*) 'your first file or path is incorrect'
      endif
      inquire(file=path(2),EXIST=file_exists)
      if(file_exists .eqv. .true.)then
         open(15,file=path(2))      
      else
         write(*,*) 'your second file or path is incorrect'
      endif
!--- get end of rightside file
!12343 continue
!      read(15,*,IOSTAT=Reason) unk, ileft, iright, reads!, ruds
!!      reads=ruds
!      if(Reason.gt.0)then
!         write(*,*) 'there was an error in input file ', path(1)
!      elseif(Reason.eq.0)then 
!         irsided = iright
!         go to 12343
!      endif
!      close(15)
!      open(15,file=path(2))      

!----
      nlines=0
12345 continue
      read(12,*,IOSTAT=Reason) unk, ileft, iright, reads!, ruds
!      reads=ruds
      if(Reason.gt.0)then
         write(*,*) 'there was an error in input file ', path(1)
      elseif(Reason.eq.0)then 
         ameans=ameans+reads
         ameans2=ameans2+reads*reads
         if(reads.gt.axm)axm=reads
         nlines=nlines+1
         go to 12345
      endif


      ameans = ameans/dble(nlines) ! computed mean signal - dominated by non-peaks typically
      ameans2 = ameans2/dble(nlines) ! take the assumptions to use this in E(x^2)-(E(x))^2 
!      write(*,*) nlines, axm
!      write(*,*) names
      close(12)!close it and reopen it or rewind
      open(12,file=path(1))      
!counted lines and got the max in file1 (path(1))

!      open(12,file="NAME1.ce") !or12
      open(14,file=TRIM(names(1))//".peakss") !or14
!-------------------------------

!      open(15,file="NAME2.ce") !or 15
      open(13,file=TRIM(names(2))//".peakss") !or 13
      open(81,file=TRIM(names(1))//"-"//TRIM(names(2))//".outs")

      open(99,file='2Dcomp')

      ipeaks=0
      npeaks=4000

      itrack=0
      tracks=0d0
      ipos=0
      ist=0
      axe=0d0
      !testing on means of signal
      edge=ameans!       0.03d0*axm!normal  0.05
      thres=ameans+sigmas*sqrt(ameans2-ameans**2)!  0.04d0*axm!normal 0.15
      write(*,*) ameans, sqrt(ameans2-ameans**2)
      do i=1,nlines
         read(12,*) unk, ileft, iright, reads!, ruds
!      reads=ruds
      if(ileft.gt.20000)then!skipping start of chrs
         if(reads.gt.edge.and.itrack.eq.0)then
            itrack=1
            istart=ileft
         endif
         if(itrack.eq.1.and.reads.ge.edge)then!stop tracking at timeofvanishing
            if(reads.gt.axe)then
            axe=reads
            ilbig=ileft
            irbig=iright
            endif
            ist=ist+1
            tracks(ist)=reads
            ipos(ist)=int(dble(ileft+iright)/2d0)
            if(ist.le.npeaks)iedge(ist,1)=ileft
            if(ist.le.npeaks)iedge(ist,2)=iright
            iend=iright
         endif
         if(itrack.eq.1.and.reads.lt.edge)then
            dist=dabs(dble(iend-istart))

!            if(axe.gt.thres.and.ipos(ist)-ipos(1).lt.100000)then  !dont take goofy gaps
!            if(axe.gt.thres.and.ipos(ist)-ipos(1).lt.100000.and.ist.gt.1)then
!            if(axe.gt.thres.and.((ipos(ist)-ipos(1))/bwidth/1.2).le.ist)then!avoid sparse regions as they are noisy in shape
            if(axe.gt.thres.and.ist.ge.0)then  !no domain-width screen here, ist>=0

!               if(ipeaks.le.npeaks)then
!!                  write(14,*) unk, ilbig, irbig
!                  do j=1,ist
!                     write(14,*) ipos(j), tracks(j), iedge(j,1), iedge(j,2)
!                  enddo
!                  write(14,*)
!                  call flush(14)
!               endif
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            !ultimately, build this to avoid reading full file
            !using a goto instead of a do
            !....done

            !right now I have a peak, stored in tracks()
            !so find the same region in the other AB data.
               ist2=0    
               tracks2=0
               axe2=0d0
54321          continue
               read(15,*,IOSTAT=Reason) unk2, ileft2, iright2, reads2!, ruds
!      reads2=ruds
               if(Reason.lt.0)then
                  !stop work
                  ileft2=0
                  iright2=0
                  reads2=0
                  go to 65432 !jump out - check alternative end
               endif
               !so either embed logic to handle this here or simply grep out 
               !each chr and batch run. - opt for batch for now.
               j=ileft2
               k=iright2

               if(istart.le.iright2.and.ileft2.le.iend)then
!               if(j.ge.istart-1000.and.k.le.iend+1000)then !switch this to overlap code??
                  ist2=ist2+1
                  ipos2(ist2)=int(dble(ileft2+iright2)/2d0)
                  if(ist2.le.npeaks)iedge2(ist2,1)=ileft2
                  if(ist2.le.npeaks)iedge2(ist2,2)=iright2
                  tracks2(ist2)=reads2
                  axe2=max(reads2,axe2)
               endif
               if(k.gt.iend)go to 65432 !jump out if hit a bin outside range
               go to 54321      !jump up
65432          continue         !out now

!               if(ipeaks.le.npeaks)then
!                  do j=1,ist2
!                     write(13,*) ipos2(j), tracks2(j), iedge2(j,1), iedge2(j,2)
!                  enddo
!                  write(13,*)
!                  call flush(13)
!               endif

               !if the reference peak is huge, assume a gap in reads and skip out
               !this is usually a big empty space where nothing maps
               !in general we know the resolution of the data and we can 
               !check the distance covered makes no sense at this resolution
               !we just do the cheap thing here for now -
               !which is the filter on gaps above
               covered=0d0
               covered2=0d0
               do k=1,ist
                  if(k.lt.ist)covered=covered+(ipos(k+1)-ipos(k))
               enddo
               do k=1,ist2
                  if(k.lt.ist2)covered2=covered2+(ipos2(k+1)-ipos2(k))
               enddo
!               if(covered.lt.100000.and.covered2.lt.100000)then!covered IF

               ipeaks=ipeaks+1

               !now i have two peaks, so get Frechet distance
               !but if one peak isn't real, just max out distance
!this can lead to false negatives
               !so i'm here, need to do frechet.
               !should map to unitless coords first, tracks are written so do whatever
               tracks=tracks/axe
               tracks2=tracks2/axe2
               do k=1,ist
                  rpos(k)=dble((ipos(k)-ipos(1)))/ &
                      dble(ipos(ist)-ipos(1))
               enddo
               do k=1,ist2
                  rpos2(k)=dble((ipos2(k)-ipos2(1)))/ &
                      dble(ipos2(ist2)-ipos2(1))
               enddo
               
               swin=1000000d0
               dfwin=swin
               s=5d0
               del=0.1d0!0.1 and 47 normal:can decrease but seems not too significant
!--- STEEPEST DOWNHILL
               if(0.eq.1)then
               call frech(tracks,tracks2,rpos,rpos2,ist,ist2,s,df)
               df0=df
               sw0=s
               s=s-del ! THIS need move to +
               n=1
6756           continue
               call frech(tracks,tracks2,rpos,rpos2,ist,ist2,s,df)
               delf= (df-df0)/del
               s=s+delf * del
!               write(*,*) n, s, delf/abs(delf), delf, df 
               df0=df
               sw0=s
               if(df.le.dfwin)then
                  dfwin=df
                  swin=s
               endif

!               del=del*0.99
               n=n+1
               if(abs(delf).gt.0.000001.and.n.lt.470)go to 6756
               endif
               !dont optimize on scale!
               s=1d0
               df=0d0
               call frech(tracks,tracks2,rpos,rpos2,ist,ist2,s,df)
               dfwin=df
               swin=s
               

!               do n=1,470
!               call frech(tracks,tracks2,rpos,rpos2,ist,ist2,s,df)         
!               if(df.le.dfwin)then
!                  dfwin=df
!                  swin=s
!               endif
!               s=s-del
!               enddo

                  !on a 0,1 range we dont need to flip the metric
               s=swin
               df=dfwin
 6666          continue
               strack=0d0
               strack2=0d0
               do m=1,ist
                  strack=strack+tracks(m)*axe
               enddo
               do m=1,ist2
                  strack2=strack2+tracks2(m)*axe2
               enddo
               if(strack2.eq.0)then
                  strack=100d0 !write a reply but not inf
                  strack2=1d0
               endif
!         write(81,2001) ipeaks, unk, istart, iend, df, s, axe/axe2, &
         write(81,2001) ipeaks, unk, istart, iend, df, s, strack/strack2, &
                   strack, strack2, axe, axe2, ilbig, irbig
 2001    format (13(1X,g0))
               ean1=ean1+df
               ean2=ean2+s
               if(df.lt.2)then!drop null
               ddf = (2d0-0d0)/40d0
               iihist=int(df/ddf)+1
               histo(iihist)=histo(iihist)+1d0
               endif
               call flush(6)
               if(Reason.lt.0)go to 44444 !end of file 2
!               if(iright2.eq.irsided)go to 44444 !end of file 2
!            else
!               write(*,*) covered, covered2, "dead"
!            endif!covered if

            endif
            itrack=0
            tracks=0d0
            ipos=0
            ist=0
            axe=0d0
         endif

      endif         
      enddo
44444 continue
98765 continue
      write(99,*) ean1/dble(ipeaks), ean2/dble(ipeaks)
      close(12)
      close(14)
      close(13)
      close(15)
      sum=0d0
      do i=1,40
         sum=sum+histo(i)
      enddo
      do i=1,40
         ddf = (2d0-0d0)/40d0
         write(92,*) ddf*(i-0.5), histo(i)/sum
      enddo

      end program

      subroutine frech(ts,ts2,ps,ps2,isp,isp2,s,df)
      real*8 ts(100000),ts2(100000)
      real*8 ca(10000,10000),a1,a2,di,df,s
      real*8 ps(100000)
      real*8 ps2(100000)

      integer isp,isp2

      do k=1,isp
         do l=1,isp2
            ca(k,l)=-1d0                     
               di=sqrt( (ts(k)-s*ts2(l))**2 &
                   +(ps(k)-ps2(l))**2)

            if(ca(k,l).gt.-1d0)then
               fd = ca(k,l)
            elseif(k.eq.1.and.l.eq.1)then
               ca(k,l)=di
            elseif(k.gt.1.and.l.eq.1)then
               ca(k,l)=max(ca(k-1,l),di)
            elseif(k.eq.1.and.l.gt.1)then
               ca(k,l)=max(ca(k,l-1),di)
            elseif(k.gt.1.and.l.gt.1)then
               a1=min(ca(k-1,l),ca(k-1,l-1))
               a2=min(a1,ca(k,l-1))
               ca(k,l)=max(di,a2)
            endif
         enddo
      enddo
      if(isp2.ne.0)then
         df = ca(isp,isp2)
      else
         df = 100d0
      endif
      return
      end subroutine
      
