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
      [gender] NVARCHAR(10) NOT NULL CHECK (gender IN ('MALE', 'FEMALE','OTHER')),
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

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'employee_phone_number')
BEGIN
    CREATE TABLE [employee_phone_number] (
      [ssn] INT NOT NULL,
      [phone_number] VARCHAR(50) NOT NULL,
      PRIMARY KEY ([ssn],[phone_number]),
      CONSTRAINT [fk_emp_phone_number] FOREIGN KEY ([ssn]) REFERENCES [employee] ([ssn]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'full_time_employee')
BEGIN
    CREATE TABLE [full_time_employee] (
      [ssn] INT NOT NULL,
      [insurance] VARCHAR(50) NOT NULL,
      [month_salary] DECIMAL(10,2) NOT NULL,
      PRIMARY KEY ([ssn]),
      CONSTRAINT [fk_ft_emp] FOREIGN KEY ([ssn]) REFERENCES [employee] ([ssn]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'part_time_employee')
BEGIN
    CREATE TABLE [part_time_employee] (
      [ssn] INT NOT NULL,
      [hourly_salary] DECIMAL(10,2) NOT NULL,
      PRIMARY KEY ([ssn]),
      CONSTRAINT [fk_pt_emp] FOREIGN KEY ([ssn]) REFERENCES [employee] ([ssn]) ON DELETE CASCADE
    );
END;


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'part_time_employee_works')
BEGIN
    CREATE TABLE [part_time_employee_works] (
      [ssn] INT NOT NULL,
      [date] DATE NOT NULL,
      [shift] NVARCHAR(50) NOT NULL CHECK (shift IN ('7:00 AM - 12:00 AM','12:00 AM - 17:00 PM','17:00 PM - 22:00 PM')),
      PRIMARY KEY ([ssn],[date],[shift]),
      CONSTRAINT [fk_pt_emp_works] FOREIGN KEY ([ssn]) REFERENCES [employee] ([ssn]) ON DELETE CASCADE
    );
END;


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'employee_dependent')
BEGIN
    CREATE TABLE [employee_dependent] (
      [ssn] INT NOT NULL,
      [name] NVARCHAR(50) NOT NULL,
      [relationship] NVARCHAR(50) NOT NULL,
      [phone_number] VARCHAR(50) NOT NULL,
      [address] VARCHAR(500) NOT NULL,
      [date_of_birth] DATE NOT NULL,
      [gender] NVARCHAR(10) NOT NULL,
      [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
      [updated_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
      PRIMARY KEY ([ssn],[name]),
      CONSTRAINT [fk_emp_dependent] FOREIGN KEY ([ssn]) REFERENCES [employee] ([ssn]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'supplier_invoice')
BEGIN
    CREATE TABLE [supplier_invoice] (
      [id] INT NOT NULL IDENTITY(1,1),
      [date] DATE NOT NULL,
      [time] TIME NOT NULL,
      PRIMARY KEY ([id])
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'supplier')
BEGIN
    CREATE TABLE [supplier] (
      [supplier_name] NVARCHAR(50) NOT NULL,
      PRIMARY KEY ([supplier_name])
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'supplier_invoice_item')
BEGIN
    CREATE TABLE [supplier_invoice_item] (
      [product_name] NVARCHAR(50) NOT NULL,
      [unit] NVARCHAR(50) NOT NULL,
      [price] DECIMAL(10,2) NOT NULL,
      PRIMARY KEY ([product_name])
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'supply')
BEGIN
    CREATE TABLE [supply] (
      [quantity] INT NOT NULL,
      [supplier_name] NVARCHAR(50) NOT NULL,
      [supplier_invoice_id] INT NOT NULL,
      [product_name] NVARCHAR(50) NOT NULL,
      PRIMARY KEY ([supplier_name],[supplier_invoice_id],[product_name]),
      CONSTRAINT [fk_supply_supplier] FOREIGN KEY ([supplier_name]) REFERENCES [supplier] ([supplier_name]) ON DELETE CASCADE,
      CONSTRAINT [fk_supply_supplier_invoice] FOREIGN KEY ([supplier_invoice_id]) REFERENCES [supplier_invoice] ([id]) ON DELETE CASCADE,
      CONSTRAINT [fk_supply_supplier_invoice_item] FOREIGN KEY ([product_name]) REFERENCES [supplier_invoice_item] ([product_name]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'check_supplier_invoice')
BEGIN
    CREATE TABLE [check_supplier_invoice] (
      [ssn] INT NOT NULL,
      [supplier_invoice_id] INT NOT NULL,
      PRIMARY KEY ([ssn],[supplier_invoice_id]),
      CONSTRAINT [fk_emp_check_supplier_invoice] FOREIGN KEY ([ssn]) REFERENCES [employee] ([ssn]) ON DELETE CASCADE,
      CONSTRAINT [fk_supplier_invoice_check_supplier_invoice] FOREIGN KEY ([supplier_invoice_id]) REFERENCES [supplier_invoice] ([id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'item_in_store')
BEGIN
    CREATE TABLE [item_in_store] (
      [product_name] NVARCHAR(50) NOT NULL,
      [unit] NVARCHAR(50) NOT NULL,
      [remaining_quantity] DECIMAL(10,2) NOT NULL,
      [supplier_invoice_id] INT NOT NULL,
      PRIMARY KEY ([product_name]),
      CONSTRAINT [fk_item_in_store_supplier_invoice] FOREIGN KEY ([supplier_invoice_id]) REFERENCES [supplier_invoice] ([id]) ON DELETE CASCADE
    );
END;

GO


-- Trigger
-- 1. Create trigger to update super_ssn to NULL when delete employee
IF OBJECT_ID('dbo.trigger_DeleteEmployee', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trigger_DeleteEmployee;
GO

CREATE TRIGGER trg_DeleteEmployee
ON dbo.employee
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE e
    SET e.super_ssn = NULL
    FROM dbo.employee e
    INNER JOIN deleted d ON e.super_ssn = d.ssn;

    DELETE FROM dbo.employee WHERE ssn IN (SELECT ssn FROM deleted);
END;
GO



-- Insert data
-- 1. Insert data for employee table
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

-- 2. Insert data for employee_phone_number table
INSERT INTO [employee_phone_number] ([ssn], [phone_number])
VALUES 
(1, '0123456789'),
(2, '0987654321'),
(3, '0123456789'),
(4, '0987654321'),
(5, '0123456789'),
(6, '0987654321'),
(7, '0123456789'),
(8, '0987654321'),
(9, '0123456789'),
(10, '0987654321'),
(11, '0123456789'),
(12, '0987654321'),
(13, '0123456789'),
(14, '0987654321'),
(15, '0123456789'),
(16, '0987654321'),
(17, '0123456789'),
(18, '0987654321'),
(19, '0123456789'),
(20, '0987654321'),
(21, '0123456789'),
(22, '0987654321'),
(23, '0123456789'),
(24, '0987654321'),
(25, '0123456789'),
(26, '0987654321'),
(27, '0123456789'),
(28, '0987654321'),
(29, '0123456789'),
(30, '0987654321'),
(1, '0999999999'),
(2, '0888888888'),
(3, '0777777777'),
(4, '0123123444'),
(5, '7877867687'),
(6, '2344324234'),
(7, '5454123534'),
(8, '4321231231'),
(9, '0738274823'),
(10, '0782374861');