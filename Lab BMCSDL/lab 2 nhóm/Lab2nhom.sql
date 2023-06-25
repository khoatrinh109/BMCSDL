use QLBongDa

go
--e)
create proc SP_SEL_NO_ENCRYPT
(
	@tenclb NVARCHAR(100),
	@tenqg NVARCHAR(100) 
)
As
	Begin
		select CT.MACT, CT.HOTEN, CT.NGAYSINH, CT.DIACHI, CT.VITRI 
		from CAUTHU CT join CAULACBO CLB on CT.MACLB = CLB.MACLB 
				       join QUOCGIA QG on CT.MAQG = QG.MAQG
		where CLB.TENCLB = @tenclb and QG.TENQG = @tenqg
	END



----drop procedure SP_SEL_NO_ENCRYPT
go

--f)
create proc SP_SEL_ENCRYPT @tenclb NVARCHAR(100), @tenqg NVARCHAR(100) 
with ENCRYPTION 
As
	Begin
		select CT.MACT, CT.HOTEN, CT.NGAYSINH, CT.DIACHI, CT.VITRI 
		from dbo.CAUTHU CT join dbo.CAULACBO CLB on CT.MACLB = CLB.MACLB 
							join dbo.QUOCGIA QG on CT.MAQG = QG.MAQG
		where CLB.TENCLB = @tenclb and QG.TENQG = @tenqg
	End
go


exec sp_helptext 'SP_SEL_ENCRYPT';
exec sp_helptext 'SP_SEL_NO_ENCRYPT';


execute SP_SEL_NO_ENCRYPT N'SHB Đà Nẵng' ,  'Brazil' ;
execute SP_SEL_ENCRYPT N'SHB Đà Nẵng' , 'Brazil' ;
go


--h)
--vCau1
CREATE VIEW vCAU1 AS
SELECT MACT,HOTEN, DIACHI, VITRI, NGAYSINH 
FROM CAUTHU CT join CAULACBO CLB on CT.MACLB= CLB.MACLB
			join QUOCGIA QG on QG.MAQG = CT.MAQG
WHERE QG.TENQG='Brazil' and CLB.TENCLB=N'SHB Đà Nẵng';
go
--vCau2
CREATE VIEW vCAU2 as
SELECT MATRAN, NGAYTD, clb1.TENCLB as TENCLB1,clb2.TENCLB as TENCLB2, SANVD.TENSAN,TRANDAU.KETQUA
from TRANDAU join CAULACBO as clb1 on TRANDAU.MACLB1=clb1.MACLB
				join CAULACBO as clb2 on TRANDAU.MACLB2=clb2.MACLB
				join SANVD on TRANDAU.MASAN=SANVD.MASAN
where TRANDAU.NAM='2009' and TRANDAU.VONG='3' and clb1.TENCLB!=clb2.TENCLB
go
--vCau3
create view vCau3 as
	select HLV.MAHLV, HLV.TENHLV, HLV.NGAYSINH, HLV.DIACHI, HLV_CLB.VAITRO, CLB.TENCLB
	from HLV_CLB  join HUANLUYENVIEN as HLV on HLV.MAHLV = HLV_CLB.MAHLV
				  join QUOCGIA as QG on HLV.MAQG = QG.MAQG
				  join CAULACBO as CLB on HLV_CLB.MACLB = CLB.MACLB
	where QG.TENQG like N'Việt Nam'
go
--vCau4
CREATE VIEW vCAU4 as
select CAULACBO.MACLB, CAULACBO.TENCLB, SANVD.TENSAN, SANVD.DIACHI, COUNT(CAULACBO.MACLB) as SOCAUTHUNUOCNGOAI
from CAUTHU join CAULACBO on CAUTHU.MACLB=CAULACBO.MACLB
			join SANVD on CAULACBO.MASAN=SANVD.MASAN
			join QUOCGIA on CAUTHU.MAQG=QUOCGIA.MAQG
where QUOCGIA.TENQG!=N'Việt Nam'
group by CAULACBO.MACLB,CAULACBO.TENCLB, SANVD.TENSAN, SANVD.DIACHI
having COUNT(CAULACBO.MACLB)>2
go
--vCau5
create view vCAU5 as 
select TINH.TENTINH, count(ct.VITRI) as SOLUONGCAUTHUTIENDAO
from TINH join CAULACBO clb on clb.MATINH=TINH.MATINH
			join CAUTHU ct on ct.MACLB=clb.MACLB
where ct.VITRI=N'Tiền Đạo'
group by TINH.TENTINH
go
--vCau6
create view vCAU6 as
select CAULACBO.TENCLB, TINH.TENTINH
from BANGXH join CAULACBO on BANGXH.MACLB=CAULACBO.MACLB
			join TINH on CAULACBO.MATINH= TINH.MATINH
where BANGXH.VONG='3' and BANGXH.HANG='1'
go
--vCau7
create view vCau7 as
	select HLV.TENHLV
	from HLV_CLB join HUANLUYENVIEN as HLV on HLV_CLB.MAHLV = HLV.MAHLV
				 join CAULACBO as CLB on HLV_CLB.MACLB = CLB.MACLB
	where HLV.DIENTHOAI is null and HLV_CLB.VAITRO is not null 
go
--vCau8
create view vCau8 as
	select HLV.TENHLV
	from HUANLUYENVIEN as HLV inner join QUOCGIA as QG on HLV.MAQG = QG.MAQG
	where QG.TENQG <> N'Việt Nam'
	except
	select HLV.TENHLV
	from HLV_CLB inner join HUANLUYENVIEN as HLV on HLV_CLB.MAHLV = HLV.MAHLV
	     		 inner join CAULACBO as CLB on HLV_CLB.MACLB = CLB.MACLB
go
--vCau9
create view vCau9 as
	select TD.NGAYTD, SVD.TENSAN, CLB1.TENCLB as TENCLB1, CLB2.TENCLB as TENCLB2, TD.KETQUA
	from TRANDAU as TD inner join SANVD as SVD on TD.MASAN = SVD.MASAN
					   inner join CAULACBO as CLB1 on TD.MACLB1 = CLB1.MACLB
					   inner join CAULACBO as CLB2 on TD.MACLB2 = CLB2.MACLB
					   inner join (select top(1) BANGXH.MACLB, BANGXH.VONG, BANGXH.NAM
								   from BANGXH
								   where BANGXH.VONG = 3 and BANGXH.NAM = 2009
								   order by BANGXH.DIEM desc) as BXH on BXH.NAM >= TD.NAM and BXH.VONG >= TD.VONG and BXH.MACLB = TD.MACLB1
	union
	select TD.NGAYTD, SVD.TENSAN, CLB1.TENCLB as TENCLB1, CLB2.TENCLB as TENCLB2, TD.KETQUA
	from TRANDAU as TD inner join SANVD as SVD on TD.MASAN = SVD.MASAN
					   inner join CAULACBO as CLB1 on TD.MACLB1 = CLB1.MACLB
					   inner join CAULACBO as CLB2 on TD.MACLB2 = CLB2.MACLB
					   inner join (select top(1) BANGXH.MACLB, BANGXH.VONG, BANGXH.NAM
								   from BANGXH
								   where BANGXH.VONG = 3 and BANGXH.NAM = 2009
								   order by BANGXH.DIEM desc) as BXH on BXH.NAM >= TD.NAM and BXH.VONG >= TD.VONG and BXH.MACLB = TD.MACLB2 
go
--vCau10
create view vCau10 as
	select TD.NGAYTD, SVD.TENSAN, CLB1.TENCLB as TENCLB1, CLB2.TENCLB as TENCLB2, TD.KETQUA
	from TRANDAU as TD inner join SANVD as SVD on TD.MASAN = SVD.MASAN
					   inner join CAULACBO as CLB1 on TD.MACLB1 = CLB1.MACLB
					   inner join CAULACBO as CLB2 on TD.MACLB2 = CLB2.MACLB
					   inner join (select top(1) BANGXH.MACLB, BANGXH.VONG, BANGXH.NAM
								   from BANGXH
								   where BANGXH.VONG = 3 and BANGXH.NAM = 2009
								   order by BANGXH.DIEM asc) as BXH on BXH.NAM >= TD.NAM and BXH.VONG >= TD.VONG and BXH.MACLB = TD.MACLB1
	union
	select TD.NGAYTD, SVD.TENSAN, CLB1.TENCLB as TENCLB1, CLB2.TENCLB as TENCLB2, TD.KETQUA
	from TRANDAU as TD inner join SANVD as SVD on TD.MASAN = SVD.MASAN
					   inner join CAULACBO as CLB1 on TD.MACLB1 = CLB1.MACLB
					   inner join CAULACBO as CLB2 on TD.MACLB2 = CLB2.MACLB
					   inner join (select top(1) BANGXH.MACLB, BANGXH.VONG, BANGXH.NAM
								   from BANGXH
								   where BANGXH.VONG = 3 and BANGXH.NAM = 2009
								   order by BANGXH.DIEM asc) as BXH on BXH.NAM >= TD.NAM and BXH.VONG >= TD.VONG and BXH.MACLB = TD.MACLB2
go

----grant view permission----
use QLBongDa
--BDRead--
grant select,view definition to BDRead
--BDU01
grant select,view definition on vCau5 to BDU01
grant select,view definition on vCau6 to BDU01
grant select,view definition on vCau7 to BDU01
grant select,view definition on vCau8 to BDU01
grant select,view definition on vCau9 to BDU01
grant select,view definition on vCau10 to BDU01

--BDU03
grant select,view definition on vCau1 to BDU03
grant select,view definition on vCau2 to BDU03
grant select,view definition on vCau3 to BDU03
grant select,view definition on vCau4 to BDU03

--BDU04
grant select,view definition on vCau1 to BDU04
grant select,view definition on vCau2 to BDU04
grant select,view definition on vCau3 to BDU04
grant select,view definition on vCau4 to BDU04

--Test view--
--BDRead--
SELECT * FROM vCau1
SELECT * FROM vCau5
--BDU01--
SELECT * FROM vCau2
SELECT * FROM vCau10
--BDU03-- 
SELECT * FROM vCau1
SELECT * FROM vCau2
SELECT * FROM vCau3
SELECT * FROM vCau4
--BDU04--
SELECT * FROM vCau1
SELECT * FROM vCau2
SELECT * FROM vCau3
SELECT * FROM vCau4

go
--SPCau1
create proc SPCau1 @TenCLB NVARCHAR(100), @TenQG NVARCHAR(60) 
as begin
		select CT.MACT, CT.HOTEN, CT.NGAYSINH, CT.DIACHI, CT.VITRI 
		from CAUTHU as CT join CAULACBO on CT.MACLB = CAULACBO.MACLB 
						 join QUOCGIA on CT.MAQG = QUOCGIA.MAQG
		where CAULACBO.TENCLB = @TenCLB and QUOCGIA.TENQG = @TenQG
	end

EXEC SPCau1 @TenCLB = N'SHB Đà Nẵng', @TenQG = N'Brazil';
go

--SPCau2
create proc SPCau2 @Vong int, @nam int
as begin
		SELECT MATRAN, NGAYTD, clb1.TENCLB as TENCLB1,clb2.TENCLB as TENCLB2, SANVD.TENSAN,TRANDAU.KETQUA
		from TRANDAU join CAULACBO as clb1 on TRANDAU.MACLB1=clb1.MACLB
						join CAULACBO as clb2 on TRANDAU.MACLB2=clb2.MACLB
						join SANVD on TRANDAU.MASAN=SANVD.MASAN
		where TRANDAU.NAM=@nam and TRANDAU.VONG=@vong and clb1.TENCLB!=clb2.TENCLB
	end
go

Exec SPCau2 @vong = '3', @nam = '2009'
go

--SPCau3
create proc SPCau3 @TenQG NVARCHAR(60) 
as begin
		select HLV.MAHLV, HLV.TENHLV, HLV.NGAYSINH, HLV.DIACHI, HLV_CLB.VAITRO, CLB.TENCLB
		from HLV_CLB join HUANLUYENVIEN as HLV on HLV.MAHLV = HLV_CLB.MAHLV
					 join QUOCGIA as QG on HLV.MAQG = QG.MAQG
					 join CAULACBO as CLB on HLV_CLB.MACLB = CLB.MACLB
		where QG.TENQG = @TenQG
	end

exec spCau3 @tenqg = N'Việt Nam'
go

--SPCau4
CREATE proc spCau4  @TenQG NVARCHAR(60)
as begin
		select CAULACBO.MACLB, CAULACBO.TENCLB, SANVD.TENSAN, SANVD.DIACHI, COUNT(CAULACBO.MACLB) as SOCAUTHUNUOCNGOAI
		from CAUTHU join CAULACBO on CAUTHU.MACLB=CAULACBO.MACLB
					join SANVD on CAULACBO.MASAN=SANVD.MASAN
					join QUOCGIA on CAUTHU.MAQG=QUOCGIA.MAQG
		where QUOCGIA.TENQG!=@TenQG
		group by CAULACBO.MACLB,CAULACBO.TENCLB, SANVD.TENSAN, SANVD.DIACHI
		having COUNT(CAULACBO.MACLB)>2;
	end

exec spCau4 @tenqg  = N'Việt Nam'
go

--SPCau5
create proc SPCau5 @Vitri NVARCHAR(20) 
as begin
		select TINH.TENTINH, count(ct.VITRI) as SOLUONGCAUTHUTIENDAO
		from TINH join CAULACBO clb on clb.MATINH=TINH.MATINH
				  join CAUTHU ct on ct.MACLB=clb.MACLB
		where ct.VITRI=@Vitri
		group by TINH.TENTINH
	end

exec spCau5 @vitri = N'Tiền Đạo'
go


--SPCau6
create proc SPCau6 @Vong int, @Hang int
as begin
		select CAULACBO.TENCLB, TINH.TENTINH
		from BANGXH join CAULACBO on BANGXH.MACLB=CAULACBO.MACLB
					join TINH on CAULACBO.MATINH= TINH.MATINH
		where BANGXH.VONG=@Vong and BANGXH.HANG=@Hang
	end

exec SPCau6 @vong = '3', @hang = '1'
go

--SPCau7
create proc SPCau7 @VaiTro NVARCHAR(100)
as begin
		select HLV.TENHLV
		from HLV_CLB join HUANLUYENVIEN as HLV on HLV_CLB.MAHLV = HLV.MAHLV
					 join CAULACBO as CLB on HLV_CLB.MACLB = CLB.MACLB
		where HLV.DIENTHOAI is null and HLV_CLB.VAITRO = @VaiTro 				
	end
exec SPCau7 @VaiTro='HLV chính'
go

--SPCau8
create proc SPCau8 @tenqg NVARCHAR(100)
as begin
		select HLV.TENHLV
		from HUANLUYENVIEN as HLV inner join QUOCGIA as QG on HLV.MAQG = QG.MAQG
		where QG.TENQG <> @tenqg
		except
		select HLV.TENHLV
		from HLV_CLB inner join HUANLUYENVIEN as HLV on HLV_CLB.MAHLV = HLV.MAHLV
	     			inner join CAULACBO as CLB on HLV_CLB.MACLB = CLB.MACLB
	end

exec spCau8  @tenqg = N'Việt Nam'
go

--SPCau9
create proc SPCau9 @Vong int, @Nam int
as begin
	select TD.NGAYTD, SVD.TENSAN, CLB1.TENCLB as TENCLB1, CLB2.TENCLB as TENCLB2, TD.KETQUA
	from TRANDAU as TD inner join SANVD as SVD on TD.MASAN = SVD.MASAN
					   inner join CAULACBO as CLB1 on TD.MACLB1 = CLB1.MACLB
					   inner join CAULACBO as CLB2 on TD.MACLB2 = CLB2.MACLB
					   inner join (select top(1) BANGXH.MACLB, BANGXH.VONG, BANGXH.NAM
								   from BANGXH
								   where BANGXH.VONG = @Vong and BANGXH.NAM = @Nam
								   order by BANGXH.DIEM desc) as BXH on BXH.NAM >= TD.NAM and BXH.VONG >= TD.VONG and BXH.MACLB = TD.MACLB1
	union
	select TD.NGAYTD, SVD.TENSAN, CLB1.TENCLB as TENCLB1, CLB2.TENCLB as TENCLB2, TD.KETQUA
	from TRANDAU as TD inner join SANVD as SVD on TD.MASAN = SVD.MASAN
					   inner join CAULACBO as CLB1 on TD.MACLB1 = CLB1.MACLB
					   inner join CAULACBO as CLB2 on TD.MACLB2 = CLB2.MACLB
					   inner join (select top(1) BANGXH.MACLB, BANGXH.VONG, BANGXH.NAM
								   from BANGXH
								   where BANGXH.VONG = @Vong and BANGXH.NAM = @Nam
								   order by BANGXH.DIEM desc) as BXH on BXH.NAM >= TD.NAM and BXH.VONG >= TD.VONG and BXH.MACLB = TD.MACLB2 
	end
exec spCau9 @Vong = '3' , @Nam = '2009'
go

--SPCau10
create proc SPCau10 @Vong int, @Nam int
as begin
	select TD.NGAYTD, SVD.TENSAN, CLB1.TENCLB as TENCLB1, CLB2.TENCLB as TENCLB2, TD.KETQUA
	from TRANDAU as TD inner join SANVD as SVD on TD.MASAN = SVD.MASAN
					   inner join CAULACBO as CLB1 on TD.MACLB1 = CLB1.MACLB
					   inner join CAULACBO as CLB2 on TD.MACLB2 = CLB2.MACLB
					   inner join (select top(1) BANGXH.MACLB, BANGXH.VONG, BANGXH.NAM
								   from BANGXH
								   where BANGXH.VONG = @Vong and BANGXH.NAM = @Nam
								   order by BANGXH.DIEM asc) as BXH on BXH.NAM >= TD.NAM and BXH.VONG >= TD.VONG and BXH.MACLB = TD.MACLB1
	union
	select TD.NGAYTD, SVD.TENSAN, CLB1.TENCLB as TENCLB1, CLB2.TENCLB as TENCLB2, TD.KETQUA
	from TRANDAU as TD inner join SANVD as SVD on TD.MASAN = SVD.MASAN
					   inner join CAULACBO as CLB1 on TD.MACLB1 = CLB1.MACLB
					   inner join CAULACBO as CLB2 on TD.MACLB2 = CLB2.MACLB
					   inner join (select top(1) BANGXH.MACLB, BANGXH.VONG, BANGXH.NAM
								   from BANGXH
								   where BANGXH.VONG = @Vong and BANGXH.NAM = @Nam
								   order by BANGXH.DIEM asc) as BXH on BXH.NAM >= TD.NAM and BXH.VONG >= TD.VONG and BXH.MACLB = TD.MACLB2

	end

exec spCau10 @vong = '3', @nam = '2009'
go

--grant stored procedure permission--
use QLBongDa
--BDRead--
grant execute to BDRead

--BDU01

grant execute on object::SPCAU5 to BDU01
grant execute on object::SPCau6 to BDU01
grant execute on object::SPCau7 to BDU01
grant execute on object::SPCau8 to BDU01
grant execute on object::SPCau9 to BDU01
grant execute on object::SPCau10 to BDU01

--BDU03
grant execute on object::SPCau1 to BDU03
grant execute on object::SPCau2 to BDU03
grant execute on object::SPCau3 to BDU03
grant execute on object::SPCau4 to BDU03

--BDU04
grant execute on object::SPCau1 to BDU04
grant execute on object::SPCau2 to BDU04
grant execute on object::SPCau3 to BDU04
grant execute on object::SPCau4 to BDU04

--test SP--
--BDRead--
exec SPCau1 N'SHB Đà Nẵng', N'Brazil'
exec SPCau9 3, 2009
--BDU01--
exec SPCau3 N'Việt Nam'
exec SPCau10 3, 2009
--BDU03--
exec SPCau1 N'SHB Đà Nẵng', N'Brazil'
exec SPCau3 N'Việt Nam'
exec SPCau4 N'Việt Nam'
exec SPCau10 3, 2009
--BDU04--
exec SPCau1 N'SHB Đà Nẵng', N'Brazil'
exec SPCau3 N'Việt Nam'
exec SPCau4 N'Việt Nam'
exec SPCau10 3, 2009