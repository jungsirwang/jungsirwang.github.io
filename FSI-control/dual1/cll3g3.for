      subroutine cll3g3(coorr,coefr,
     & prmt,estif,emass,edamp,eload,num)
c .... coorr ---- nodal coordinate value
c .... coefr ---- nodal coef value
      implicit real*8 (a-h,o-z)
      dimension estif(6,6),elump(6),emass(6),
     & eload(6)
      dimension prmt(*),coef(2),coefr(3,2),coorr(1,3),coor(1)
      common /rcll3g3/ru(3,6),rv(3,6),
     & cu(3,2),cv(3,2)
c .... store shape functions and their partial derivatives
c .... for all integral points
      common /vcll3g3/rctr(1,1),crtr(1,1),coefd(2,2),coefc(2,2)
      common /dcll3g3/ refc(1,3),gaus(3),
     & nnode,ngaus,ndisp,nrefc,ncoor,nvar,
     & nvard(2),kdord(2),kvord(6,2)
c .... nnode ---- the number of nodes
c .... nrefc ---- the number of numerical integral points
c .... ndisp ---- the number of unknown functions
c .... nrefc ---- the number of reference coordinates
c .... nvar ---- the number of unknown varibles var
c .... refc ---- reference coordinates at integral points
c .... gaus ---- weight number at integral points
c .... nvard ---- the number of var for each unknown
c .... kdord ---- the highest differential order for each unknown
c .... kvord ---- var number at integral points for each unknown
      data=prmt(1)
      time=prmt(2)
      dt=prmt(3)
      imate=prmt(4)+0.5
      ielem=prmt(5)+0.5
      nelem=prmt(6)+0.5
      it=prmt(7)+0.5
      nmate=prmt(8)+0.5
      itime=prmt(9)+0.5
      ityp=prmt(10)+0.5
      if (num.eq.1) call cll3g3i
c .... initialize the basic data
      do 10 i=1,nvar
      eload(i)=0.0
      do 10 j=1,nvar
      estif(i,j)=0.0
10    continue
      do 999 igaus=1,ngaus
      call cll3g3t(nnode,nrefc,ncoor,refc(1,igaus),coor,coorr,
     & rctr,crtr,det,coefr)
c .... coordinate transfer from reference to original system
c .... rctr ---- Jacobi's matrix
c .... crtr ---- inverse matrix of Jacobi's matrix
      x=coor(1)
      rx=refc(1,igaus)
      call ecll3g3(refc(1,igaus),coef,coorr,coefr,coefd)
c .... compute coef functions and their partial derivatives
      iu=(igaus-1)*2+1
      iv=(igaus-1)*2+1
      if (num.gt.1) goto 2
c .... the following is the shape function caculation
      call cll3g31(refc(1,igaus),ru(1,iu),rctr,crtr)
      call cll3g32(refc(1,igaus),rv(1,iv),rctr,crtr)
2     continue
c .... the following is the shape function transformation
c .... from reference coordinates to original coordinates
      call shapn(nrefc,ncoor,3,ru(1,iu),cu,crtr,1,2,2)
      call shapn(nrefc,ncoor,3,rv(1,iv),cv,crtr,1,2,2)
c .... the coef function transformation
c .... from reference coordinates to original coordinates
      call shapc(nrefc,ncoor,2,coefd,coefc,crtr,2,2,2)
      un=coef(1)
      vn=coef(2)
      weigh=det*gaus(igaus)
c .... the following is the stiffness computation
      do 202 i=1,3
      iv=kvord(i,1)
      do 201 j=1,3
      jv=kvord(j,1)
      stif=+cu(i,1)*cu(j,1)*0.d0
      estif(iv,jv)=estif(iv,jv)+stif*weigh
201    continue
202    continue
c .... the following is the load vector computation
      do 501 i=1,3
      iv=kvord(i,1)
      stif=+cu(i,1)*un
      eload(iv)=eload(iv)+stif*weigh
501   continue
      do 502 i=1,3
      iv=kvord(i,2)
      stif=+cv(i,1)*vn
      eload(iv)=eload(iv)+stif*weigh
502   continue
999   continue
998   continue
      return
      end

      subroutine cll3g3i
      implicit real*8 (a-h,o-z)
      common /dcll3g3/ refc(1,3),gaus(3),
     & nnode,ngaus,ndisp,nrefc,ncoor,nvar,
     & nvard(2),kdord(2),kvord(6,2)
c .... initial data
c .... refc ---- reference coordinates at integral points
c .... gaus ---- weight number at integral points
c .... nvard ---- the number of var for each unknown
c .... kdord ---- the highest differential order for each unknown
c .... kvord ---- var number at integral points for each unknown
      ngaus=  3
      ndisp=  2
      nrefc=  1
      ncoor=  1
      nvar =  6
      nnode=  3
      kdord(1)=1
      nvard(1)=3
      kvord(1,1)=1
      kvord(2,1)=5
      kvord(3,1)=3
      kdord(2)=1
      nvard(2)=3
      kvord(1,2)=2
      kvord(2,2)=6
      kvord(3,2)=4
      refc(1,1)=7.745966692e-001
      gaus(1)=5.555555556e-001
      refc(1,2)=0.000000000e+000
      gaus(2)=8.888888889e-001
      refc(1,3)=-7.745966692e-001
      gaus(3)=5.555555556e-001
      end


      subroutine cll3g3t(nnode,nrefc,ncoor,refc,coor,coorr,
     & rc,cr,det,coefr)
      implicit real*8 (a-h,o-z)
      dimension refc(nrefc),rc(ncoor,nrefc),cr(nrefc,ncoor),a(5,10),
     & coorr(ncoor,nnode),coor(ncoor),coefr(nnode,*)
      call tcll3g3(refc,coor,coorr,coefr,rc)
      n=nrefc
      m=n*2
      det = 1.0
      do 10 i=1,n
      do 10 j=1,n
      if (i.le.ncoor) a(i,j) = rc(i,j)
      if (i.gt.ncoor) a(i,j)=1.0
      a(i,n+j)=0.0
      if (i.eq.j) a(i,n+i) = 1.0
10    continue
c     write(*,*) 'a ='
c     do 21 i=1,n
c21   write(*,8) (a(i,j),j=1,m)
      do 400 i=1,n
      amax = 0.0
      l = 0
      do 50 j=i,n
      c = a(j,i)
      if (c.lt.0.0) c = -c
      if (c.le.amax) goto 50
      amax = c
      l = j
50    continue
      do 60 k=1,m
      c = a(l,k)
      a(l,k) = a(i,k)
      a(i,k) = c
60    continue
      c = a(i,i)
      det = c*det
      do 100 k=i+1,m
100   a(i,k) = a(i,k)/c
      do 300 j=1,n
      if (i.eq.j) goto 300
      do 200 k=i+1,m
200   a(j,k) = a(j,k)-a(i,k)*a(j,i)
c     write(*,*) 'i =',i,'  j =',j,'  a ='
c     do 11 ii=1,n
c11   write(*,8) (a(ii,jj),jj=1,m)
300   continue
400   continue
      do 500 i=1,nrefc
      do 500 j=1,ncoor
500   cr(i,j) = a(i,n+j)
c     write(*,*) 'a ='
c     do 22 i=1,n
c22   write(*,8) (a(i,j),j=1,m)
c     write(*,*) 'rc ='
c     do 24 i=1,ncoor
c24   write(*,8) (rc(i,j),j=1,nrefc)
c     write(*,*) 'cr ='
c     do 23 i=1,nrefc
c23   write(*,8) (cr(i,j),j=1,ncoor)
c     write(*,*) 'det =',det
      if (det.lt.0.0) det=-det
c     write(*,*) 'det =',det
8     format(1x,6f12.3)
      end

      subroutine cll3g31(refc,shpr,rctr,crtr)
c .... compute shape functions and their partial derivatives
c .... shapr ---- store shape functions and their partial derivatives
      implicit real*8 (a-h,o-z)
      dimension refc(1),shpr(3,2),rctr(1,1),crtr(1,1)
      external fcll3g31
      rx=refc(1)
      call dshap(fcll3g31,refc,shpr,1,3,1)
c .... shape function and their derivatives computation
c .... compute partial derivatives by centered difference
c .... which is in the file ccshap.for of FEPG library
      return
      end

      real*8 function fcll3g31(refc,n)
c .... shape function caculation
      implicit real*8 (a-h,o-z)
      common /cccll3g3/ xa(3),una(3),vna(3)
      common /vcll3g3/ rctr(1,1),crtr(1,1),coefd(2,2),coefc(2,2)
      dimension refc(1)
      common /coord/ coor(3),coora(27,3)
      x=coor(1)
      rx=refc(1)
      goto (1,2,3) n
1     fcll3g31=+rx*(+rx-1.)/2. 
      goto 1000
2     fcll3g31=+(+1.-rx**2) 
      goto 1000
3     fcll3g31=+rx*(+1.+rx)/2. 
      goto 1000
1000  return
      end

      subroutine cll3g32(refc,shpr,rctr,crtr)
c .... compute shape functions and their partial derivatives
c .... shapr ---- store shape functions and their partial derivatives
      implicit real*8 (a-h,o-z)
      dimension refc(1),shpr(3,2),rctr(1,1),crtr(1,1)
      external fcll3g32
      rx=refc(1)
      call dshap(fcll3g32,refc,shpr,1,3,1)
c .... shape function and their derivatives computation
c .... compute partial derivatives by centered difference
c .... which is in the file ccshap.for of FEPG library
      return
      end

      real*8 function fcll3g32(refc,n)
c .... shape function caculation
      implicit real*8 (a-h,o-z)
      common /cccll3g3/ xa(3),una(3),vna(3)
      common /vcll3g3/ rctr(1,1),crtr(1,1),coefd(2,2),coefc(2,2)
      dimension refc(1)
      common /coord/ coor(3),coora(27,3)
      x=coor(1)
      rx=refc(1)
      goto (1,2,3) n
1     fcll3g32=+rx*(+rx-1.)/2. 
      goto 1000
2     fcll3g32=+(+1.-rx**2) 
      goto 1000
3     fcll3g32=+rx*(+1.+rx)/2. 
      goto 1000
1000  return
      end

      subroutine tcll3g3(refc,coor,coorr,coefr,rc)
c .... compute coordinate value and Jacobi's matrix rc
c .... by reference coordinate value
      implicit real*8 (a-h,o-z)
      dimension refc(1),coor(1),coorr(1,3),coefr(3,2),rc(1,1)
      common /cccll3g3/ x(3),un(3),vn(3)
      external ftcll3g3
      do 100 n=1,3
      x(n)=coorr(1,n)
100   continue
      do 200 n=1,3
      un(n)=coefr(n,1)
      vn(n)=coefr(n,2)
200   continue
      rx=refc(1)
      call dcoor(ftcll3g3,refc,coor,rc,1,1,1)
c .... coordinate value and their partial derivatives caculation
c .... compute partial derivatives by centered difference
c .... which is in the file ccshap.for of FEPG library
      return
      end

      real*8 function ftcll3g3(refc,n)
c .... coordinate transfer function caculation
      implicit real*8 (a-h,o-z)
      dimension refc(1)
      common /cccll3g3/ x(3),un(3),vn(3)
      common /vcll3g3/ rctr(1,1),crtr(1,1),coefd(2,2),coefc(2,2)
      rx=refc(1)
      goto (1) n
1     ftcll3g3=+(+rx*(+rx-1.)/2.)*x(1)+(+(+1.-rx**2))*x(3)
     & +(+rx*(+1.+rx)/2.)*x(2)
      goto 1000
1000  return
      end

      subroutine ecll3g3(refc,coef,coorr,coefr,coefd)
c .... compute coef value and their partial derivatives
c .... by reference coordinate value
      implicit real*8 (a-h,o-z)
      dimension refc(1),coef(2),coorr(1,3),coefr(3,2),coefd(2,1)
      external fecll3g3
      rx=refc(1)
      call dcoef(fecll3g3,refc,coef,coefd,1,2,2)
c .... coef value and their partial derivatives caculation
c .... compute partial derivatives by centered difference
c .... which is in the file ccshap.for of FEPG library
      return
      end

      real*8 function fecll3g3(refc,n)
c .... coef function caculation
      implicit real*8 (a-h,o-z)
      dimension refc(1)
      common /cccll3g3/ xa(3),un(3),vn(3)
      common /vcll3g3/ rctr(1,1),crtr(1,1),coefd(2,2),coefc(2,2)
      common /coord/ coor(3),coora(27,3)
      x=coor(1)
      rx=refc(1)
      goto (1,2) n
1     fecll3g3=+(+rx*(+rx-1.)/2.)*un(1)+(+(+1.-rx**2))*un(3)
     & +(+rx*(+1.+rx)/2.)*un(2)
      goto 1000
2     fecll3g3=+(+rx*(+rx-1.)/2.)*vn(1)+(+(+1.-rx**2))*vn(3)
     & +(+rx*(+1.+rx)/2.)*vn(2)
      goto 1000
1000  return
      end

