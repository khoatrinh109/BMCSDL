/*----------------------------------------------------------
MASV: 46.01.104.001
HO TEN: Nguyễn Quốc An
LAB: 03
NGAY: 23/03/2023
----------------------------------------------------------*/
--CAU LENH TAO DB

CREATE DATABASE QLSV
GO
USE QLSV
GO

/*----------------------------------------------------------
MASV: 46.01.104.001
HO TEN: Nguyễn Quốc An
LAB: 03
NGAY: 23/03/2023
----------------------------------------------------------*/
--CAC CAU LENH TAO TABLE 

use QLSV
go


create table SINHVIEN
(
	MASV		NVARCHAR(20),
	HOTEN		NVARCHAR(100)		NOT NULL,
	NGAYSINH	DATETIME,
	DIACHI		NVARCHAR(200),
	MALOP		VARCHAR(20),
	TENDN		NVARCHAR(100)		NOT NULL,
	MATKHAU		VARBINARY(MAX)			NOT NULL,
	
	PRIMARY KEY(MASV)
)

create table NHANVIEN
(
	MANV	VARCHAR(20),
	HOTEN	NVARCHAR(100)	NOT NULL,
	EMAIL	VARCHAR(20),
	LUONG	VARBINARY(MAX),
	TENDN	NVARCHAR(100)	NOT NULL,
	MATKHAU	VARBINARY(MAX)		NOT NULL,

	PRIMARY KEY(MANV)
)
create table LOP
(
	MALOP	VARCHAR(20),
	TENLOP	NVARCHAR(100)	NOT NULL,
	MANV	VARCHAR(20),

	PRIMARY KEY(MALOP)
)



/*----------------------------------------------------------
MASV: 46.01.104.001
HO TEN: Nguyễn Quốc An
LAB: 03
NGAY: 23/03/2023
----------------------------------------------------------*/
-- CAU LENH TAO STORED PROCEDURE


use QLSV
go

create proc SP_INS_SINHVIEN 
	@masv NVARCHAR(20), 
	@hoten NVARCHAR(100),
	@ngaysinh DATETIME, 
	@diachi NVARCHAR(200), 
	@malop VARCHAR(20), 
	@tendn NVARCHAR(100), 
	@matkhau VARCHAR(20)
as
	begin
		insert SINHVIEN(MASV, HOTEN, NGAYSINH, DIACHI, MALOP, TENDN, MATKHAU)
		values(@masv, @hoten,@ngaysinh,@diachi,@malop,@tendn,HashBytes('MD5', @matkhau))
	end
go



--tao master key
IF NOT EXISTS
(
	SELECT *
	FROM sys.symmetric_keys
	WHERE symmetric_key_id = 101
)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '4601104001'--Ma sinh vien
GO 

--tao certificates
IF NOT EXISTS
(
	SELECT *
	FROM sys.certificates
	WHERE name = 'MyCert'
)
CREATE CERTIFICATE MyCert 
WITH SUBJECT = 'MyCert';
GO
 
--tao symmetric key
IF NOT EXISTS
(
	SELECT *
	FROM sys.symmetric_keys
	WHERE name = 'PriKey'
)

CREATE SYMMETRIC KEY PriKey
	WITH ALGORITHM = AES_256
	ENCRYPTION BY CERTIFICATE MyCert;
GO

-- encrypt data

OPEN SYMMETRIC KEY PriKey
DECRYPTION BY CERTIFICATE MyCert;
GO

create proc SP_INS_NHANVIEN
	@MANV VARCHAR(20),
	@HOTEN NVARCHAR(100),
	@EMAIL VARCHAR(20),
	@LUONG int,
	@TENDN NVARCHAR(100),
	@MATKHAU VARCHAR(20)
as 
	begin
		insert nhanvien(MANV, HOTEN, EMAIL, LUONG, TENDN, MATKHAU)
		values(@MANV,@HOTEN,@EMAIL, ENCRYPTBYKEY(KEY_GUID('PriKey'),convert(varbinary,@LUONG)),@TENDN,HashBytes('SHA1',@MATKHAU))
	end
go




create proc SP_SEL_NHANVIEN
as
	begin
		OPEN SYMMETRIC KEY PriKey
		DECRYPTION BY CERTIFICATE MyCert
		SELECT MANV, HOTEN, EMAIL, convert(int,DECRYPTBYKEY(LUONG)) AS LUONGCB
		FROM NHANVIEN
	end
GO



--nhap lieu

--NHANVIEN
EXEC SP_INS_NHANVIEN 'NV01', 'NGUYEN VAN A', 'NVA@', 3000000, 'NVA', 'abcd12'
select * from NHANVIEN

--LOP
INSERT INTO LOP VALUES('CNTT', N'Công Nghệ Thông Tin', 'NV01');

--SINHVIEN
EXEC SP_INS_SINHVIEN '4601104001', 'Nguyen Van A', '01/11/1990', 'TP.HCM', 'CNTT', '4601104001', '4601104001'
select * from SINHVIEN

EXEC SP_SEL_NHANVIEN



