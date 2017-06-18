      subroutine plotv
     a(v,s,sp,etot,eplas,ecreep,t,m,nn,kcus,ndi,nshear,jpltcd)	  
      

      implicit real *8 (a-h, o-z)
      dimension s(*),sp(*),etot(*),eplas(*),ecreep(*),t(*),m(2),
     a kcus(2)
	 
      include '../common/matdat'
	  common first_pass_GG
	  
      if (first_pass_GG.ne.1.2345d0)then
		  block_density_GG(1:10000,1)=100.0d0
		  block_density_GG(1:10000,2:5)=0.0d0
          first_pass_GG=1.2345d0
          open(101,FILE='density.txt')
          read(101,*)
          do while (.not.eof(101))
            read(101,*) aaa, bbb, ccc, ddd, eee
            i=nint(aaa)
            block_density_GG(i,1)=bbb
            block_density_GG(i,2)=ccc
			block_density_GG(i,3)=ddd
			block_density_GG(i,4)=eee
          enddo
          rewind(101)
          close(101)
      endif
          
      if(jpltcd.eq.1)then
			v=et(1)
      elseif(jpltcd.eq.2)then
			v=block_density_GG(m(1),1)
      elseif(jpltcd.eq.3)then
			v=block_density_GG(m(1),2)
      elseif(jpltcd.eq.4)then
			v=block_density_GG(m(1),3)
      elseif(jpltcd.eq.5)then
			v=block_density_GG(m(1),4)
      endif

      return
      end