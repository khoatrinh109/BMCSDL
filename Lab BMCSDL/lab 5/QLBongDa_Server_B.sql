/*----------------------------------------------------------
MASV: 43.01.104.080
HO TEN: Trịnh Anh Khoa
LAB: 05
NGAY: 19/4/2023
----------------------------------------------------------*/

USE master;
GO
CREATE MASTER KEY ENCRYPTION 
BY PASSWORD = '1234';  
GO
CREATE CERTIFICATE TDECertB
  FROM FILE = N'D:\Certificate_Backup.cer'
  WITH PRIVATE KEY ( 
    FILE = N'D:\PK_Backup.pvk',
 DECRYPTION BY PASSWORD = '12345'
  );
GO