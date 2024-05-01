USE master;
GO

IF DB_ID(N'coffee management') IS NOT NULL
BEGIN
    ALTER DATABASE [coffee management] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [coffee management];
END
GO

CREATE DATABASE [coffee management];
GO

USE [coffee management];
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'employee')
BEGIN
    CREATE TABLE [employee] (
      [ssn] INT NOT NULL IDENTITY(1,1),
      [cccd] NVARCHAR(50) NOT NULL,
      [address] NVARCHAR(500) NOT NULL,
      [job_type] NVARCHAR(100) NOT NULL,
      [date_of_work] DATETIME2 NOT NULL DEFAULT GETDATE(),
      [gender] NVARCHAR(10) NOT NULL,
      [date_of_birth] DATE NOT NULL,
      [last_name] NVARCHAR(50) NOT NULL,
      [middle_name] NVARCHAR(50) NOT NULL,
      [first_name] NVARCHAR(50) NOT NULL,
      [super_ssn] INT DEFAULT NULL,
      [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
      [updated_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
      PRIMARY KEY ([ssn]),
      UNIQUE ([cccd]),
      CONSTRAINT [fk_emp_superssn] FOREIGN KEY ([super_ssn]) REFERENCES [employee] ([ssn])
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'employee')
BEGIN
    CREATE TABLE [employee] (
      [ssn] INT NOT NULL IDENTITY(1,1),
      [cccd] NVARCHAR(50) NOT NULL,
      [address] NVARCHAR(500) NOT NULL,
      [job_type] NVARCHAR(100) NOT NULL,
      [date_of_work] DATETIME2 NOT NULL DEFAULT GETDATE(),
      [gender] NVARCHAR(10) NOT NULL,
      [date_of_birth] DATE NOT NULL,
      [last_name] NVARCHAR(50) NOT NULL,
      [middle_name] NVARCHAR(50) NOT NULL,
      [first_name] NVARCHAR(50) NOT NULL,
      [super_ssn] INT DEFAULT NULL,
      [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
      [updated_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
      PRIMARY KEY ([ssn]),
      UNIQUE ([cccd]),
      CONSTRAINT [fk_emp_superssn] FOREIGN KEY ([super_ssn]) REFERENCES [employee] ([ssn])
    );
END;

GO


-- Trigger
-- 1. Create trigger to update super_ssn to NULL when delete employee
IF OBJECT_ID('dbo.trigger_DeleteEmployee', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trigger_DeleteEmployee;
GO

CREATE TRIGGER trigger_DeleteEmployee
ON dbo.employee
BEFORE DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.employee
    SET super_ssn = NULL
    WHERE super_ssn IN (SELECT ssn FROM deleted);
END;
GO


INSERT INTO [employee] ([cccd], [address], [job_type], [date_of_work], [gender], [date_of_birth], [last_name], [middle_name], [first_name]) 
VALUES 
(N'AB123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2024-04-30 09:00:00', N'MALE', '1980-05-15', N'Nguyễn', N'Văn', N'An'),
(N'CD987654321', N'456 Đường Lê Lợi, Thành phố Hà Nội', N'Thu Ngân', '2024-04-29 08:30:00', N'FEMALE', '1985-10-20', N'Trần', N'Thị', N'Bích'),
(N'EF456123789', N'789 Đường Lý Tự Trọng, Thành phố Đà Nẵng', N'Pha chế', '2024-04-28 08:00:00', N'MALE', '1990-03-25', N'Lê', N'Hữu', N'Quốc'),
(N'GH789456123', N'101 Đường Trần Hưng Đạo, Thành phố Cần Thơ', N'Phục vụ', '2024-04-27 07:30:00', N'FEMALE', '1995-08-10', N'Phạm', N'Thị', N'Hoài'),
(N'IJ321654987', N'201 Đường Nguyễn Huệ, Thành phố Hải Phòng', N'Bảo vệ', '2024-04-26 07:00:00', N'MALE', '1998-12-05', N'Hoàng', N'Văn', N'Bảo'),
(N'KL321987321', N'301 Đường Võ Văn Kiệt, Thành phố Bình Dương', N'Thu Ngân', '2024-04-25 06:30:00', N'FEMALE', '1987-02-20', N'Ngô', N'Thị', N'Dung'),
(N'MN654987321', N'401 Đường Trần Phú, Thành phố Hải Dương', N'Phục vụ', '2024-04-24 06:00:00', N'MALE', '1992-07-15', N'Vũ', N'Đình', N'Anh'),
(N'OP789321654', N'501 Đường Bà Triệu, Thành phố Huế', N'Phục vụ', '2024-04-23 05:30:00', N'FEMALE', '1996-11-30', N'Đặng', N'Thị', N'Ly'),
(N'QR987321654', N'601 Đường Phan Đình Phùng, Thành phố Vũng Tàu', N'Pha chế', '2024-04-22 05:00:00', N'MALE', '1989-04-25', N'Trương', N'Văn', N'Tuấn'),
(N'ST321789654', N'701 Đường Nguyễn Du, Thành phố Nha Trang', N'Bảo vệ', '2024-04-21 04:30:00', N'FEMALE', '1994-09-10', N'Bùi', N'Thị', N'Nga'),
(N'UV123789654', N'801 Đường Nguyễn Thị Minh Khai, Thành phố Long Xuyên', N'Pha chế', '2024-04-20 04:00:00', N'MALE', '1986-01-20', N'Lý', N'Văn', N'Hải'),
(N'WX987654321', N'901 Đường Phạm Văn Đồng, Thành phố Thủ Dầu Một', N'Phục vụ', '2024-04-19 03:30:00', N'FEMALE', '1993-06-15', N'Mai', N'Thị', N'Hương'),
(N'YZ789123654', N'1001 Đường Nguyễn Thái Học, Thành phố Quy Nhơn', N'Phục vụ', '2024-04-18 03:00:00', N'MALE', '1988-11-10', N'Đoàn', N'Văn', N'Thành'),
(N'AB456987123', N'1101 Đường Lý Thường Kiệt, Thành phố Bắc Ninh', N'Bảo vệ', '2024-04-17 02:30:00', N'FEMALE', '1991-04-05', N'Võ', N'Thị', N'Mỹ'),
(N'CD654321789', N'1201 Đường Phan Chu Trinh, Thành phố Hòa Bình', N'Pha chế', '2024-04-16 02:00:00', N'MALE', '1984-09-30', N'Đinh', N'Văn', N'Dũng');

INSERT INTO [employee] ([cccd], [address], [job_type], [date_of_work], [gender], [date_of_birth], [last_name], [middle_name], [first_name], [super_ssn]) 
VALUES 
(N'XX123456784', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2024-04-30 09:00:00', N'MALE', '1980-05-15', N'Nguyễn', N'Văn', N'An',1),
(N'XX123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2024-04-30 09:00:00', N'MALE', '1980-05-15', N'Nguyễn', N'Văn', N'An', 1),
(N'YY234567890', N'456 Đường Lê Lợi, Thành phố Hà Nội', N'Thu Ngân', '2024-04-29 08:30:00', N'FEMALE', '1985-10-20', N'Trần', N'Thị', N'Bích', 2),
(N'ZZ345678901', N'789 Đường Lý Tự Trọng, Thành phố Đà Nẵng', N'Pha chế', '2024-04-28 08:00:00', N'MALE', '1990-03-25', N'Lê', N'Hữu', N'Quốc', 3),
(N'AA456789012', N'101 Đường Trần Hưng Đạo, Thành phố Cần Thơ', N'Phục vụ', '2024-04-27 07:30:00', N'FEMALE', '1995-08-10', N'Phạm', N'Thị', N'Hoài', 4),
(N'BB567890123', N'201 Đường Nguyễn Huệ, Thành phố Hải Phòng', N'Bảo vệ', '2024-04-26 07:00:00', N'MALE', '1998-12-05', N'Hoàng', N'Văn', N'Bảo', 5),
(N'CC678901234', N'301 Đường Võ Văn Kiệt, Thành phố Bình Dương', N'Thu Ngân', '2024-04-25 06:30:00', N'FEMALE', '1987-02-20', N'Ngô', N'Thị', N'Dung', 6),
(N'DD789012345', N'401 Đường Trần Phú, Thành phố Hải Dương', N'Phục vụ', '2024-04-24 06:00:00', N'MALE', '1992-07-15', N'Vũ', N'Đình', N'Anh', 7),
(N'EE890123456', N'501 Đường Bà Triệu, Thành phố Huế', N'Phục vụ', '2024-04-23 05:30:00', N'FEMALE', '1996-11-30', N'Đặng', N'Thị', N'Ly', 8),
(N'FF901234567', N'601 Đường Phan Đình Phùng, Thành phố Vũng Tàu', N'Pha chế', '2024-04-22 05:00:00', N'MALE', '1989-04-25', N'Trương', N'Văn', N'Tuấn', 9),
(N'GG012345678', N'701 Đường Nguyễn Du, Thành phố Nha Trang', N'Bảo vệ', '2024-04-21 04:30:00', N'FEMALE', '1994-09-10', N'Bùi', N'Thị', N'Nga', 10),
(N'HH123456789', N'801 Đường Nguyễn Thị Minh Khai, Thành phố Long Xuyên', N'Pha chế', '2024-04-20 04:00:00', N'MALE', '1986-01-20', N'Lý', N'Văn', N'Hải', 11),
(N'II234567890', N'901 Đường Phạm Văn Đồng, Thành phố Thủ Dầu Một', N'Phục vụ', '2024-04-19 03:30:00', N'FEMALE', '1993-06-15', N'Mai', N'Thị', N'Hương', 12),
(N'JJ345678901', N'1001 Đường Nguyễn Thái Học, Thành phố Quy Nhơn', N'Phục vụ', '2024-04-18 03:00:00', N'MALE', '1988-11-10', N'Đoàn', N'Văn', N'Thành', 13),
(N'KK456789012', N'1101 Đường Lý Thường Kiệt, Thành phố Bắc Ninh', N'Bảo vệ', '2024-04-17 02:30:00', N'FEMALE', '1991-04-05', N'Võ', N'Thị', N'Mỹ', 14);
