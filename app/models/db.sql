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

-- Create tables
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

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'employee_supplier_invoice')
BEGIN
    CREATE TABLE [employee_supplier_invoice] (
      [ssn] INT NOT NULL,
      [supplier_invoice_id] INT NOT NULL,
      PRIMARY KEY ([ssn],[supplier_invoice_id]),
      CONSTRAINT [fk_emp_ssn] FOREIGN KEY ([ssn]) REFERENCES [employee] ([ssn]) ON DELETE CASCADE,
      CONSTRAINT [fk_supplier_invoice_id] FOREIGN KEY ([supplier_invoice_id]) REFERENCES [supplier_invoice] ([id]) ON DELETE CASCADE
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


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'beverage')
BEGIN
    CREATE TABLE [beverage] (
      [beverage_name] NVARCHAR(50) NOT NULL,
      PRIMARY KEY ([beverage_name])
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'size')
BEGIN
    CREATE TABLE [size] (
      [size] NVARCHAR(50) NOT NULL,
      [price] DECIMAL(10,2) NOT NULL,
      [beverage_name] NVARCHAR(50) NOT NULL,
      PRIMARY KEY ([size],[beverage_name]),
      CONSTRAINT [fk_beverage_size] FOREIGN KEY ([beverage_name]) REFERENCES [beverage] ([beverage_name]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'size_item_in_store')
BEGIN
    CREATE TABLE [size_item_in_store] (
      [product_name] NVARCHAR(50) NOT NULL,
      [size] NVARCHAR(50) NOT NULL,
      [quantity] NVARCHAR(50) NOT NULL,
      [beverage_name] NVARCHAR(50) NOT NULL,
      PRIMARY KEY ([product_name],[size],[beverage_name]),
      CONSTRAINT [fk_item_in_store_product] FOREIGN KEY ([product_name]) REFERENCES [item_in_store] ([product_name]) ON DELETE CASCADE,
      CONSTRAINT [fk_item_in_store_size] FOREIGN KEY ([size],[beverage_name]) REFERENCES [size] ([size],[beverage_name]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'customer')
BEGIN
    CREATE TABLE [customer] (
      [id] INT NOT NULL IDENTITY(1,1),
      [name] NVARCHAR(50) NOT NULL,
      [phone_number] VARCHAR(50) NOT NULL,
      [date_of_birth] DATE NOT NULL,
      PRIMARY KEY ([id])
    );
END;


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'order')
BEGIN
    CREATE TABLE [order] (
      [id] INT NOT NULL IDENTITY(1,1),
      [order_type] NVARCHAR(50) NOT NULL,
      [note] NVARCHAR(500) DEFAULT NULL,
      [employee_ssn] INT NOT NULL,
      [customer_id] INT DEFAULT NULL,
      PRIMARY KEY ([id]),
      CONSTRAINT [fk_order_employee] FOREIGN KEY ([employee_ssn]) REFERENCES [employee] ([ssn]) ON DELETE CASCADE,
      CONSTRAINT [fk_order_customer] FOREIGN KEY ([customer_id]) REFERENCES [customer] ([id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'customer_order')
BEGIN
    CREATE TABLE [customer_order] (
      [customer_id] INT NOT NULL,
      [order_id] INT NOT NULL,
      [comment] NVARCHAR(500) DEFAULT NULL,
      PRIMARY KEY ([order_id]),
      CONSTRAINT [fk_customer_order_customer] FOREIGN KEY ([customer_id]) REFERENCES [customer] ([id]) ON DELETE CASCADE,
      CONSTRAINT [fk_customer_order_order] FOREIGN KEY ([order_id]) REFERENCES [order] ([id])
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'sale_invoice')
BEGIN
    CREATE TABLE [sale_invoice] (
      [id] INT NOT NULL IDENTITY(1,1),
      [date] DATE NOT NULL,
      [time] TIME NOT NULL,
      [payment_method] NVARCHAR(50) NOT NULL CHECK (payment_method IN ('CASH', 'ONLINE', 'CARD')),
      [order_id] INT NOT NULL,
      PRIMARY KEY ([id]),
      CONSTRAINT [fk_sale_invoice_order] FOREIGN KEY ([order_id]) REFERENCES [order] ([id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'size_sale_invoice')
BEGIN
    CREATE TABLE [size_sale_invoice] (
      [size] NVARCHAR(50) NOT NULL,
      [quantity] INT NOT NULL,
      [beverage_name] NVARCHAR(50) NOT NULL,
      [sale_invoice_id] INT NOT NULL,
      PRIMARY KEY ([size],[beverage_name],[sale_invoice_id]),
      CONSTRAINT [fk_size_sale_invoice_size] FOREIGN KEY ([size],[beverage_name]) REFERENCES [size] ([size],[beverage_name]) ON DELETE CASCADE,
      CONSTRAINT [fk_size_sale_invoice_sale_invoice] FOREIGN KEY ([sale_invoice_id]) REFERENCES [sale_invoice] ([id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'promotion')
BEGIN
    CREATE TABLE [promotion] (
      [id] INT NOT NULL IDENTITY(1,1),
      [promotion_name] NVARCHAR(50) NOT NULL,
      [start_date] DATE NOT NULL,
      [end_date] DATE NOT NULL,
      [discount_type] NVARCHAR(50) NOT NULL CHECK (discount_type IN ('PERCENT', 'AMOUNT')),
      [discount_value] DECIMAL(10,2) NOT NULL,
      PRIMARY KEY ([id])
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'size_promotion')
BEGIN
    CREATE TABLE [size_promotion] (
      [size] NVARCHAR(50) NOT NULL,
      [beverage_name] NVARCHAR(50) NOT NULL,
      [promotion_id] INT NOT NULL,
      [quantity] INT NOT NULL,
      PRIMARY KEY ([size],[beverage_name],[promotion_id]),
      CONSTRAINT [fk_size_promotion_size] FOREIGN KEY ([size],[beverage_name]) REFERENCES [size] ([size],[beverage_name]) ON DELETE CASCADE,
      CONSTRAINT [fk_size_promotion_promotion] FOREIGN KEY ([promotion_id]) REFERENCES [promotion] ([id]) ON DELETE CASCADE
    );
END;


-- Chưa rõ định nghĩa chỗ bàn
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'table')
BEGIN
    CREATE TABLE [table] (
      [id] INT NOT NULL IDENTITY(1,1),
      [number_seat] INT NOT NULL,
      PRIMARY KEY ([id])
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'order_table')
BEGIN
    CREATE TABLE [order_table] (
      [order_id] INT NOT NULL,
      [table_id] INT NOT NULL,
      PRIMARY KEY ([table_id]),
      CONSTRAINT [fk_order_table_order] FOREIGN KEY ([order_id]) REFERENCES [order] ([id]) ON DELETE CASCADE,
      CONSTRAINT [fk_order_table_table] FOREIGN KEY ([table_id]) REFERENCES [table] ([id]) ON DELETE CASCADE
    );
END;


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'promotion_order')
BEGIN
    CREATE TABLE [promotion_order] (
      [order_id] INT NOT NULL,
      [promotion_id] INT NOT NULL,
      PRIMARY KEY ([order_id]),
      CONSTRAINT [fk_promotion_order_order] FOREIGN KEY ([order_id]) REFERENCES [order] ([id]) ON DELETE CASCADE,
      CONSTRAINT [fk_promotion_order_promotion] FOREIGN KEY ([promotion_id]) REFERENCES [promotion] ([id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'delivery_service')
BEGIN
    CREATE TABLE [delivery_service] (
      [id] INT NOT NULL IDENTITY(1,1),
      [name] NVARCHAR(50) NOT NULL,
      PRIMARY KEY ([id])
    );
END;


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'delivery_service_order')
BEGIN
    CREATE TABLE [delivery_service_order] (
      [tracking_code] NVARCHAR(50) NOT NULL,
      [order_id] INT NOT NULL,
      [delivery_service_id] INT NOT NULL,
      PRIMARY KEY ([order_id]),
      CONSTRAINT [fk_delivery_service_order_order] FOREIGN KEY ([order_id]) REFERENCES [order] ([id]) ON DELETE CASCADE,
      CONSTRAINT [fk_delivery_service_order_delivery_service] FOREIGN KEY ([delivery_service_id]) REFERENCES [delivery_service] ([id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'size_order')
BEGIN
    CREATE TABLE [size_order] (
      [size] NVARCHAR(50) NOT NULL,
      [beverage_name] NVARCHAR(50) NOT NULL,
      [order_id] INT NOT NULL,
      [quantity] INT NOT NULL,
      PRIMARY KEY ([size],[beverage_name],[order_id]),
      CONSTRAINT [fk_size_order_size] FOREIGN KEY ([size],[beverage_name]) REFERENCES [size] ([size],[beverage_name]) ON DELETE CASCADE,
      CONSTRAINT [fk_size_order_order] FOREIGN KEY ([order_id]) REFERENCES [order] ([id]) ON DELETE CASCADE
    );
END;
GO

-- Procedure to insert, update, delete employee
-- 1. Create procedure to insert employee
IF OBJECT_ID('dbo.proc_InsertEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_InsertEmployee;
GO

CREATE PROCEDURE dbo.proc_InsertEmployee
    @cccd NVARCHAR(50),
    @address NVARCHAR(500),
    @job_type NVARCHAR(100),
    @date_of_work DATETIME2,
    @gender NVARCHAR(10),
    @date_of_birth DATE,
    @last_name NVARCHAR(50),
    @middle_name NVARCHAR(50),
    @first_name NVARCHAR(50),
    @list_phone_number VARCHAR(MAX),
    @super_ssn INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if employee is older than 18 years old
    IF DATEDIFF(YEAR, @date_of_birth, GETDATE()) < 18
    BEGIN
        RAISERROR('Employee must be older than 18 years old', 16, 1);
        RETURN;
    END;

    -- Check if phone numbers have valid format
    DECLARE @InvalidPhoneNumbers TABLE (PhoneNumber VARCHAR(20));
    DECLARE @ValidPhoneNumbers TABLE (PhoneNumber VARCHAR(20));

    INSERT INTO @InvalidPhoneNumbers (PhoneNumber)
    SELECT value
    FROM STRING_SPLIT(@list_phone_number, ',')
    WHERE value NOT LIKE '0[35789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]';

    -- Raise error for each invalid phone number
    DECLARE @ErrorMessage NVARCHAR(MAX);
    DECLARE @InvalidPhoneNumber NVARCHAR(20);

    DECLARE InvalidPhoneNumbersCursor CURSOR FOR
    SELECT PhoneNumber FROM @InvalidPhoneNumbers;

    OPEN InvalidPhoneNumbersCursor;
    FETCH NEXT FROM InvalidPhoneNumbersCursor INTO @InvalidPhoneNumber;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ErrorMessage = 'Invalid phone number: ' + @InvalidPhoneNumber;
        RAISERROR(@ErrorMessage, 16, 1);
        FETCH NEXT FROM InvalidPhoneNumbersCursor INTO @InvalidPhoneNumber;
    END;

    CLOSE InvalidPhoneNumbersCursor;
    DEALLOCATE InvalidPhoneNumbersCursor;

    -- Insert employee
    INSERT INTO [employee] ([cccd], [address], [job_type], [date_of_work], [gender], [date_of_birth], [last_name], [middle_name], [first_name], [super_ssn])
    VALUES (@cccd, @address, @job_type, @date_of_work, @gender, @date_of_birth, @last_name, @middle_name, @first_name, @super_ssn);

    -- Insert phone numbers for the employee into employee_phone_number table
    DECLARE @EmployeeSSN INT;
    SELECT @EmployeeSSN = SCOPE_IDENTITY();

    DECLARE @PhoneNumberList TABLE (PhoneNumber VARCHAR(20));

    INSERT INTO @PhoneNumberList (PhoneNumber)
    SELECT value
    FROM STRING_SPLIT(@list_phone_number, ',');

    INSERT INTO employee_phone_number (ssn, phone_number)
    SELECT @EmployeeSSN, PhoneNumber
    FROM @PhoneNumberList;
END;
GO


-- -- Test procedure InsertEmployee
-- DECLARE @cccd NVARCHAR(50) = '123456789';
-- DECLARE @address NVARCHAR(500) = '123 Main Street, City';
-- DECLARE @job_type NVARCHAR(100) = 'Manager';
-- DECLARE @date_of_work DATETIME2 = '2024-05-02';
-- DECLARE @gender NVARCHAR(10) = 'Male';
-- DECLARE @date_of_birth DATE = '1990-01-01';
-- DECLARE @last_name NVARCHAR(50) = 'Doe';
-- DECLARE @middle_name NVARCHAR(50) = 'John';
-- DECLARE @first_name NVARCHAR(50) = 'John';
-- DECLARE @list_phone_number VARCHAR(MAX) = '0987654321,0999999999,0965483957,0946573847';

-- EXEC dbo.proc_InsertEmployee 
--     @cccd,
--     @address,
--     @job_type,
--     @date_of_work,
--     @gender,
--     @date_of_birth,
--     @last_name,
--     @middle_name,
--     @first_name,
--     @list_phone_number,
--     NULL;
-- GO

-- 2. Create procedure to update employee
IF OBJECT_ID('dbo.proc_UpdateEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_UpdateEmployee;
GO

CREATE PROCEDURE dbo.proc_UpdateEmployee
    @ssn INT,
    @cccd NVARCHAR(50),
    @address NVARCHAR(500),
    @job_type NVARCHAR(100),
    @list_phone_number VARCHAR(MAX),
    @super_ssn INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the employee exists
    IF NOT EXISTS (SELECT * FROM employee WHERE ssn = @ssn)
    BEGIN
        RAISERROR('Employee does not exist', 16, 1);
        RETURN;
    END;

    -- Check if phone numbers have valid format
    DECLARE @InvalidPhoneNumbers TABLE (PhoneNumber VARCHAR(20));
    DECLARE @ValidPhoneNumbers TABLE (PhoneNumber VARCHAR(20));

    INSERT INTO @InvalidPhoneNumbers (PhoneNumber)
    SELECT value
    FROM STRING_SPLIT(@list_phone_number, ',')
    WHERE value NOT LIKE '0[35789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]';

    -- Raise error for each invalid phone number
    DECLARE @ErrorMessage NVARCHAR(MAX);
    DECLARE @InvalidPhoneNumber NVARCHAR(20);

    DECLARE InvalidPhoneNumbersCursor CURSOR FOR
    SELECT PhoneNumber FROM @InvalidPhoneNumbers;

    OPEN InvalidPhoneNumbersCursor;
    FETCH NEXT FROM InvalidPhoneNumbersCursor INTO @InvalidPhoneNumber;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ErrorMessage = 'Invalid phone number: ' + @InvalidPhoneNumber;
        RAISERROR(@ErrorMessage, 16, 1);
        FETCH NEXT FROM InvalidPhoneNumbersCursor INTO @InvalidPhoneNumber;
    END;

    CLOSE InvalidPhoneNumbersCursor;
    DEALLOCATE InvalidPhoneNumbersCursor;

    -- Update employee
    UPDATE e
    SET e.address = @address,
        e.cccd = @cccd,
        e.job_type = @job_type,
        e.super_ssn = @super_ssn,
        e.updated_at = GETDATE()
    FROM employee e
    WHERE e.ssn = @ssn;

    -- Update phone numbers for the employee
    DECLARE @EmployeeSSN INT;
    SELECT @EmployeeSSN = ssn
    FROM employee
    WHERE ssn = @ssn;

    DECLARE @PhoneNumberList TABLE (PhoneNumber VARCHAR(20));

    INSERT INTO @PhoneNumberList (PhoneNumber)
    SELECT value
    FROM STRING_SPLIT(@list_phone_number, ',');

    DELETE FROM employee_phone_number
    WHERE ssn = @EmployeeSSN;

    INSERT INTO employee_phone_number (ssn, phone_number)
    SELECT @EmployeeSSN, PhoneNumber
    FROM @PhoneNumberList;
END;
GO

-- -- Test procedure UpdateEmployee
-- DECLARE @ssn INT = 1;
-- DECLARE @cccd NVARCHAR(50) = '123456789';
-- DECLARE @address NVARCHAR(500) = 'HCM city';
-- DECLARE @job_type NVARCHAR(100) = 'Manager';
-- DECLARE @list_phone_number VARCHAR(MAX) = '0987654321';
-- DECLARE @super_ssn INT = 1;

-- EXEC dbo.proc_UpdateEmployee 
--     @ssn,
--     @cccd,
--     @address,
--     @job_type,
--     @list_phone_number,
--     @super_ssn;
-- GO

-- 3. Create procedure to delete employee
IF OBJECT_ID('dbo.proc_DeleteEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_DeleteEmployee;
GO

CREATE PROCEDURE dbo.proc_DeleteEmployee
    @ssn INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the employee exists
    IF NOT EXISTS (SELECT * FROM employee WHERE ssn = @ssn)
    BEGIN
        RAISERROR('Employee does not exist', 16, 1);
        RETURN;
    END;

    -- Delete employee
    DELETE FROM employee
    WHERE ssn = @ssn;
END;
GO

-- -- Test procedure DeleteEmployee
-- DECLARE @ssn INT = 1;

-- EXEC dbo.proc_DeleteEmployee @ssn;
-- GO


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

-- 2. Create trigger to count the total price of order
IF OBJECT_ID('dbo.trigger_CountTotalPrice', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trigger_CountTotalPrice;
GO

CREATE TRIGGER trg_CountTotalPrice




































-- -- Insert data
-- -- 1. Insert data for employee table
-- INSERT INTO [employee] ([cccd], [address], [job_type], [date_of_work], [gender], [date_of_birth], [last_name], [middle_name], [first_name]) 
-- VALUES 
-- (N'AB123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2024-04-30 09:00:00', N'MALE', '1980-05-15', N'Nguyễn', N'Văn', N'An'),
-- (N'CD987654321', N'456 Đường Lê Lợi, Thành phố Hà Nội', N'Thu Ngân', '2024-04-29 08:30:00', N'FEMALE', '1985-10-20', N'Trần', N'Thị', N'Bích'),
-- (N'EF456123789', N'789 Đường Lý Tự Trọng, Thành phố Đà Nẵng', N'Pha chế', '2024-04-28 08:00:00', N'MALE', '1990-03-25', N'Lê', N'Hữu', N'Quốc'),
-- (N'GH789456123', N'101 Đường Trần Hưng Đạo, Thành phố Cần Thơ', N'Phục vụ', '2024-04-27 07:30:00', N'FEMALE', '1995-08-10', N'Phạm', N'Thị', N'Hoài'),
-- (N'IJ321654987', N'201 Đường Nguyễn Huệ, Thành phố Hải Phòng', N'Bảo vệ', '2024-04-26 07:00:00', N'MALE', '1998-12-05', N'Hoàng', N'Văn', N'Bảo'),
-- (N'KL321987321', N'301 Đường Võ Văn Kiệt, Thành phố Bình Dương', N'Thu Ngân', '2024-04-25 06:30:00', N'FEMALE', '1987-02-20', N'Ngô', N'Thị', N'Dung'),
-- (N'MN654987321', N'401 Đường Trần Phú, Thành phố Hải Dương', N'Phục vụ', '2024-04-24 06:00:00', N'MALE', '1992-07-15', N'Vũ', N'Đình', N'Anh'),
-- (N'OP789321654', N'501 Đường Bà Triệu, Thành phố Huế', N'Phục vụ', '2024-04-23 05:30:00', N'FEMALE', '1996-11-30', N'Đặng', N'Thị', N'Ly'),
-- (N'QR987321654', N'601 Đường Phan Đình Phùng, Thành phố Vũng Tàu', N'Pha chế', '2024-04-22 05:00:00', N'MALE', '1989-04-25', N'Trương', N'Văn', N'Tuấn'),
-- (N'ST321789654', N'701 Đường Nguyễn Du, Thành phố Nha Trang', N'Bảo vệ', '2024-04-21 04:30:00', N'FEMALE', '1994-09-10', N'Bùi', N'Thị', N'Nga'),
-- (N'UV123789654', N'801 Đường Nguyễn Thị Minh Khai, Thành phố Long Xuyên', N'Pha chế', '2024-04-20 04:00:00', N'MALE', '1986-01-20', N'Lý', N'Văn', N'Hải'),
-- (N'WX987654321', N'901 Đường Phạm Văn Đồng, Thành phố Thủ Dầu Một', N'Phục vụ', '2024-04-19 03:30:00', N'FEMALE', '1993-06-15', N'Mai', N'Thị', N'Hương'),
-- (N'YZ789123654', N'1001 Đường Nguyễn Thái Học, Thành phố Quy Nhơn', N'Phục vụ', '2024-04-18 03:00:00', N'MALE', '1988-11-10', N'Đoàn', N'Văn', N'Thành'),
-- (N'AB456987123', N'1101 Đường Lý Thường Kiệt, Thành phố Bắc Ninh', N'Bảo vệ', '2024-04-17 02:30:00', N'FEMALE', '1991-04-05', N'Võ', N'Thị', N'Mỹ'),
-- (N'CD654321789', N'1201 Đường Phan Chu Trinh, Thành phố Hòa Bình', N'Pha chế', '2024-04-16 02:00:00', N'MALE', '1984-09-30', N'Đinh', N'Văn', N'Dũng');

-- INSERT INTO [employee] ([cccd], [address], [job_type], [date_of_work], [gender], [date_of_birth], [last_name], [middle_name], [first_name], [super_ssn]) 
-- VALUES 
-- (N'XX123456784', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2024-04-30 09:00:00', N'MALE', '1980-05-15', N'Nguyễn', N'Văn', N'An',1),
-- (N'XX123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2024-04-30 09:00:00', N'MALE', '1980-05-15', N'Nguyễn', N'Văn', N'An', 1),
-- (N'YY234567890', N'456 Đường Lê Lợi, Thành phố Hà Nội', N'Thu Ngân', '2024-04-29 08:30:00', N'FEMALE', '1985-10-20', N'Trần', N'Thị', N'Bích', 2),
-- (N'ZZ345678901', N'789 Đường Lý Tự Trọng, Thành phố Đà Nẵng', N'Pha chế', '2024-04-28 08:00:00', N'MALE', '1990-03-25', N'Lê', N'Hữu', N'Quốc', 3),
-- (N'AA456789012', N'101 Đường Trần Hưng Đạo, Thành phố Cần Thơ', N'Phục vụ', '2024-04-27 07:30:00', N'FEMALE', '1995-08-10', N'Phạm', N'Thị', N'Hoài', 4),
-- (N'BB567890123', N'201 Đường Nguyễn Huệ, Thành phố Hải Phòng', N'Bảo vệ', '2024-04-26 07:00:00', N'MALE', '1998-12-05', N'Hoàng', N'Văn', N'Bảo', 5),
-- (N'CC678901234', N'301 Đường Võ Văn Kiệt, Thành phố Bình Dương', N'Thu Ngân', '2024-04-25 06:30:00', N'FEMALE', '1987-02-20', N'Ngô', N'Thị', N'Dung', 6),
-- (N'DD789012345', N'401 Đường Trần Phú, Thành phố Hải Dương', N'Phục vụ', '2024-04-24 06:00:00', N'MALE', '1992-07-15', N'Vũ', N'Đình', N'Anh', 7),
-- (N'EE890123456', N'501 Đường Bà Triệu, Thành phố Huế', N'Phục vụ', '2024-04-23 05:30:00', N'FEMALE', '1996-11-30', N'Đặng', N'Thị', N'Ly', 8),
-- (N'FF901234567', N'601 Đường Phan Đình Phùng, Thành phố Vũng Tàu', N'Pha chế', '2024-04-22 05:00:00', N'MALE', '1989-04-25', N'Trương', N'Văn', N'Tuấn', 9),
-- (N'GG012345678', N'701 Đường Nguyễn Du, Thành phố Nha Trang', N'Bảo vệ', '2024-04-21 04:30:00', N'FEMALE', '1994-09-10', N'Bùi', N'Thị', N'Nga', 10),
-- (N'HH123456789', N'801 Đường Nguyễn Thị Minh Khai, Thành phố Long Xuyên', N'Pha chế', '2024-04-20 04:00:00', N'MALE', '1986-01-20', N'Lý', N'Văn', N'Hải', 11),
-- (N'II234567890', N'901 Đường Phạm Văn Đồng, Thành phố Thủ Dầu Một', N'Phục vụ', '2024-04-19 03:30:00', N'FEMALE', '1993-06-15', N'Mai', N'Thị', N'Hương', 12),
-- (N'JJ345678901', N'1001 Đường Nguyễn Thái Học, Thành phố Quy Nhơn', N'Phục vụ', '2024-04-18 03:00:00', N'MALE', '1988-11-10', N'Đoàn', N'Văn', N'Thành', 13),
-- (N'KK456789012', N'1101 Đường Lý Thường Kiệt, Thành phố Bắc Ninh', N'Bảo vệ', '2024-04-17 02:30:00', N'FEMALE', '1991-04-05', N'Võ', N'Thị', N'Mỹ', 14);