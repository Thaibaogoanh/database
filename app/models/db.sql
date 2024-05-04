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
      [image_url] NVARCHAR(200) DEFAULT NULL,
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
      [address] NVARCHAR(500) NOT NULL,
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
      [image_url] NVARCHAR(200) DEFAULT NULL,
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
      [total_price] DECIMAL(10,2) NOT NULL,
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
      [subTotal] DECIMAL(10,2) NULL,
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

-- CREATE PROCEDURE dbo.proc_InsertEmployee
--     @cccd NVARCHAR(50),
--     @address NVARCHAR(500),
--     @job_type NVARCHAR(100),
--     @date_of_work DATETIME2,
--     @gender NVARCHAR(10),
--     @date_of_birth DATE,
--     @last_name NVARCHAR(50),
--     @middle_name NVARCHAR(50),
--     @first_name NVARCHAR(50),
--     @list_phone_number VARCHAR(MAX),
--     @super_ssn INT
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     -- Check if employee is older than 18 years old
--     IF DATEDIFF(YEAR, @date_of_birth, GETDATE()) < 18
--     BEGIN
--         RAISERROR('Employee must be older than 18 years old', 16, 1);
--         RETURN;
--     END;

--     -- Check if phone numbers have valid format
--     DECLARE @InvalidPhoneNumbers TABLE (PhoneNumber VARCHAR(20));
--     DECLARE @ValidPhoneNumbers TABLE (PhoneNumber VARCHAR(20));

--     INSERT INTO @InvalidPhoneNumbers (PhoneNumber)
--     SELECT value
--     FROM STRING_SPLIT(@list_phone_number, ',')
--     WHERE value NOT LIKE '0[35789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]';

--     -- Raise error for each invalid phone number
--     DECLARE @ErrorMessage NVARCHAR(MAX);
--     DECLARE @InvalidPhoneNumber NVARCHAR(20);

--     DECLARE InvalidPhoneNumbersCursor CURSOR FOR
--     SELECT PhoneNumber FROM @InvalidPhoneNumbers;

--     OPEN InvalidPhoneNumbersCursor;
--     FETCH NEXT FROM InvalidPhoneNumbersCursor INTO @InvalidPhoneNumber;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         SET @ErrorMessage = 'Invalid phone number: ' + @InvalidPhoneNumber;
--         RAISERROR(@ErrorMessage, 16, 1);
--         FETCH NEXT FROM InvalidPhoneNumbersCursor INTO @InvalidPhoneNumber;
--     END;

--     CLOSE InvalidPhoneNumbersCursor;
--     DEALLOCATE InvalidPhoneNumbersCursor;

--     -- Insert employee
--     INSERT INTO [employee] ([cccd], [address], [job_type], [date_of_work], [gender], [date_of_birth], [last_name], [middle_name], [first_name], [super_ssn])
--     VALUES (@cccd, @address, @job_type, @date_of_work, @gender, @date_of_birth, @last_name, @middle_name, @first_name, @super_ssn);

--     -- Insert phone numbers for the employee into employee_phone_number table
--     DECLARE @EmployeeSSN INT;
--     SELECT @EmployeeSSN = SCOPE_IDENTITY();

--     DECLARE @PhoneNumberList TABLE (PhoneNumber VARCHAR(20));

--     INSERT INTO @PhoneNumberList (PhoneNumber)
--     SELECT value
--     FROM STRING_SPLIT(@list_phone_number, ',');

--     INSERT INTO employee_phone_number (ssn, phone_number)
--     SELECT @EmployeeSSN, PhoneNumber
--     FROM @PhoneNumberList;
-- END;

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
    @image_url NVARCHAR(200),
    @super_ssn INT,
    @ssn INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if employee is older than 18 years old
    IF DATEDIFF(YEAR, @date_of_birth, GETDATE()) < 18
    BEGIN
        RAISERROR('Employee must be older than 18 years old', 16, 1);
        RETURN;
    END;

    -- Check if employee with the same cccd already exists
    IF EXISTS (SELECT 1 FROM [employee] WHERE [cccd] = @cccd)
    BEGIN
        RAISERROR('Employee with the same cccd already exists', 16, 1);
        RETURN;
    END;

    -- Check if the super_ssn exists
    IF @super_ssn IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [employee] WHERE [ssn] = @super_ssn)
    BEGIN
        RAISERROR('Super ssn does not exist', 16, 1);
        RETURN;
    END;

    -- Insert employee
    INSERT INTO [employee] ([cccd], [address], [job_type], [date_of_work], [gender], [date_of_birth], [last_name], [middle_name], [first_name], [super_ssn],[image_url])
    VALUES (@cccd, @address, @job_type, @date_of_work, @gender, @date_of_birth, @last_name, @middle_name, @first_name, @super_ssn,@image_url);

    -- Get the ssn of the inserted employee
    SET @ssn = SCOPE_IDENTITY();
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

-- CREATE PROCEDURE dbo.proc_UpdateEmployee
--     @ssn INT,
--     @cccd NVARCHAR(50),
--     @address NVARCHAR(500),
--     @job_type NVARCHAR(100),
--     @list_phone_number VARCHAR(MAX),
--     @super_ssn INT
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     -- Check if the employee exists
--     IF NOT EXISTS (SELECT * FROM employee WHERE ssn = @ssn)
--     BEGIN
--         RAISERROR('Employee does not exist', 16, 1);
--         RETURN;
--     END;

--     -- Check if phone numbers have valid format
--     DECLARE @InvalidPhoneNumbers TABLE (PhoneNumber VARCHAR(20));
--     DECLARE @ValidPhoneNumbers TABLE (PhoneNumber VARCHAR(20));

--     INSERT INTO @InvalidPhoneNumbers (PhoneNumber)
--     SELECT value
--     FROM STRING_SPLIT(@list_phone_number, ',')
--     WHERE value NOT LIKE '0[35789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]';

--     -- Raise error for each invalid phone number
--     DECLARE @ErrorMessage NVARCHAR(MAX);
--     DECLARE @InvalidPhoneNumber NVARCHAR(20);

--     DECLARE InvalidPhoneNumbersCursor CURSOR FOR
--     SELECT PhoneNumber FROM @InvalidPhoneNumbers;

--     OPEN InvalidPhoneNumbersCursor;
--     FETCH NEXT FROM InvalidPhoneNumbersCursor INTO @InvalidPhoneNumber;

--     WHILE @@FETCH_STATUS = 0
--     BEGIN
--         SET @ErrorMessage = 'Invalid phone number: ' + @InvalidPhoneNumber;
--         RAISERROR(@ErrorMessage, 16, 1);
--         FETCH NEXT FROM InvalidPhoneNumbersCursor INTO @InvalidPhoneNumber;
--     END;

--     CLOSE InvalidPhoneNumbersCursor;
--     DEALLOCATE InvalidPhoneNumbersCursor;

--     -- Update employee
--     UPDATE e
--     SET e.address = @address,
--         e.cccd = @cccd,
--         e.job_type = @job_type,
--         e.super_ssn = @super_ssn,
--         e.updated_at = GETDATE()
--     FROM employee e
--     WHERE e.ssn = @ssn;

--     -- Update phone numbers for the employee
--     DECLARE @EmployeeSSN INT;
--     SELECT @EmployeeSSN = ssn
--     FROM employee
--     WHERE ssn = @ssn;

--     DECLARE @PhoneNumberList TABLE (PhoneNumber VARCHAR(20));

--     INSERT INTO @PhoneNumberList (PhoneNumber)
--     SELECT value
--     FROM STRING_SPLIT(@list_phone_number, ',');

--     DELETE FROM employee_phone_number
--     WHERE ssn = @EmployeeSSN;

--     INSERT INTO employee_phone_number (ssn, phone_number)
--     SELECT @EmployeeSSN, PhoneNumber
--     FROM @PhoneNumberList;
-- END;

CREATE PROCEDURE dbo.proc_UpdateEmployee
    @ssn INT,
    @cccd NVARCHAR(50) = NULL,
    @address NVARCHAR(500) = NULL,
    @job_type NVARCHAR(100) = NULL,
    @date_of_birth DATE = NULL,
    @image_url NVARCHAR(200) = NULL,
    @super_ssn INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the employee exists
    IF NOT EXISTS (SELECT * FROM employee WHERE ssn = @ssn)
    BEGIN
        RAISERROR('Employee does not exist', 16, 1);
        RETURN;
    END;

    -- Check if employee is older than 18 years old
    IF DATEDIFF(YEAR, @date_of_birth, GETDATE()) < 18
    BEGIN
        RAISERROR('Employee must be older than 18 years old', 16, 1);
        RETURN;
    END;

    -- Check if the super_ssn exists
    IF @super_ssn IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [employee] WHERE [ssn] = @super_ssn)
    BEGIN
        RAISERROR('Super ssn does not exist', 16, 1);
        RETURN;
    END;


    -- Update employee
    UPDATE e
    SET e.address = ISNULL(@address, e.address),
        e.cccd = ISNULL(@cccd, e.cccd),
        e.job_type = ISNULL(@job_type, e.job_type),
        e.super_ssn = ISNULL(@super_ssn, e.super_ssn),
        e.date_of_birth = CASE WHEN @date_of_birth IS NOT NULL THEN @date_of_birth ELSE e.date_of_birth END,
        e.image_url = ISNULL(@image_url, e.image_url),
        e.updated_at = GETDATE()
    FROM employee e
    WHERE e.ssn = @ssn;
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
IF OBJECT_ID('dbo.proc_DeleteEmployees', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_DeleteEmployees;
GO

-- CREATE PROCEDURE dbo.proc_DeleteEmployee
--     @ssn INT
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     -- Check if the employee exists
--     IF NOT EXISTS (SELECT * FROM employee WHERE ssn = @ssn)
--     BEGIN
--         RAISERROR('Employee does not exist', 16, 1);
--         RETURN;
--     END;

--     -- Delete employee
--     DELETE FROM employee
--     WHERE ssn = @ssn;
-- END;
-- GO

CREATE TYPE EmployeeSSNTableType AS TABLE  
( SSN INT
);
GO

CREATE PROCEDURE dbo.proc_DeleteEmployees
    @SSNs EmployeeSSNTableType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the employees exist
    DECLARE @MissingEmployees NVARCHAR(MAX);

    SELECT @MissingEmployees = COALESCE(@MissingEmployees + ', ', '') + CONVERT(NVARCHAR(MAX), SSN)
    FROM @SSNs
    WHERE SSN NOT IN (SELECT SSN FROM employee);

    IF @MissingEmployees IS NOT NULL
    BEGIN
        DECLARE @ErrorMessage NVARCHAR(MAX);
        SET @ErrorMessage = 'Employees with ssns ' + @MissingEmployees + ' do not exist.';
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END

    -- Delete employees
    DELETE FROM employee
    WHERE ssn IN (SELECT SSN FROM @SSNs);
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

-- 2. Create trigger to count the total price of an order



-- Stored procedure
-- 1. Create stored procedure to get employee by filter
IF OBJECT_ID('dbo.proc_GetEmployeeByFilter', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_GetEmployeeByFilter;
GO

CREATE PROCEDURE dbo.proc_GetEmployeeByFilter (
  @job_type NVARCHAR(100) = NULL,
  @phone_number VARCHAR(50) = NULL,
  @gender NVARCHAR(10) = NULL,
  @date_of_birth DATE = NULL,
  @per_page INT = 10,
  @page INT = 1,
  @total_count INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @list_ssn TABLE (ssn INT);

    -- Calculate the offset to skip records based on page size and number
    DECLARE @offset INT = (@page - 1) * @per_page;

    INSERT INTO @list_ssn (ssn)
    SELECT e.ssn
    FROM employee e
    WHERE (@job_type IS NULL OR e.job_type = @job_type)
    AND (@gender IS NULL OR e.gender = @gender)
    AND (@date_of_birth IS NULL OR e.date_of_birth = @date_of_birth)
    AND (@phone_number IS NULL OR EXISTS (SELECT 1 FROM employee_phone_number p WHERE e.ssn = p.ssn AND p.phone_number = @phone_number))
    ORDER BY e.ssn
    OFFSET @offset ROWS FETCH NEXT @per_page ROWS ONLY;


    -- Get the total count of filtered employees
    SELECT @total_count = COUNT(*)
    FROM employee e
    WHERE (@job_type IS NULL OR e.job_type = @job_type)
    AND (@gender IS NULL OR e.gender = @gender)
    AND (@date_of_birth IS NULL OR e.date_of_birth = @date_of_birth)
    AND (@phone_number IS NULL OR EXISTS (SELECT 1 FROM employee_phone_number p WHERE e.ssn = p.ssn AND p.phone_number = @phone_number));

    SELECT e.*, p.phone_number
    FROM employee e
    LEFT JOIN employee_phone_number p ON e.ssn = p.ssn 
    WHERE e.ssn IN (SELECT ssn FROM @list_ssn)
    ORDER BY e.ssn;

END;
GO

-- -- Test procedure GetEmployeeByFilter
-- DECLARE @job_type NVARCHAR(100);
-- SET @job_type = N'Phục vụ';
-- EXEC dbo.proc_GetEmployeeByFilter @job_type;


-- 2. Create stored procedure to get employee details
IF OBJECT_ID('dbo.proc_GetEmployeeDetailsFilter', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_GetEmployeeDetailsFilter;
GO

CREATE PROCEDURE GetEmployeeDetailsFilter
    @jobType NVARCHAR(100) = NULL,
    @gender NVARCHAR(10) = NULL
AS
BEGIN
    SELECT 
        e.ssn,
        e.cccd,
        e.address,
        e.job_type,
        e.date_of_work,
        e.gender,
        e.date_of_birth,
        e.last_name,
        e.middle_name,
        e.first_name,
        e.image_url,
        COUNT(DISTINCT epn.phone_number) AS phone_numbers_count,
        COUNT(DISTINCT ed.name) AS dependents_count
    FROM 
        employee e
    LEFT JOIN 
        employee_phone_number epn ON e.ssn = epn.ssn
    LEFT JOIN 
        employee_dependent ed ON e.ssn = ed.ssn
    WHERE 
        (@jobType IS NULL OR e.job_type = @jobType)
        AND (@gender IS NULL OR e.gender = @gender)
    GROUP BY 
        e.ssn, e.cccd, e.address, e.job_type, e.date_of_work, 
        e.gender, e.date_of_birth, e.last_name, e.middle_name, 
        e.first_name, e.image_url
    ORDER BY 
        e.last_name, e.first_name;
END
GO












-- Function
-- Hàm tính tổng số lượng sản phẩm đã bán của một loại sản phẩm cụ thể trong một khoảng thời gian nhất định:
CREATE FUNCTION dbo.CalculateTotalSalesForProduct (
    @ProductID INT,
    @StartDate DATE,
    @EndDate DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalSales INT = 0;
    DECLARE @QuantitySold INT;

    -- Declare cursor
    DECLARE ProductCursor CURSOR FOR
        SELECT Quantity
        FROM Sales
        WHERE ProductID = @ProductID
        AND SaleDate BETWEEN @StartDate AND @EndDate;

    -- Open cursor
    OPEN ProductCursor;

    FETCH NEXT FROM ProductCursor INTO @QuantitySold;

    -- Calculate total quantity sold
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @TotalSales = @TotalSales + @QuantitySold;
        FETCH NEXT FROM ProductCursor INTO @QuantitySold;
    END;

    -- Close cursor
    CLOSE ProductCursor;
    DEALLOCATE ProductCursor;

    RETURN @TotalSales;
END;
GO

-- Hàm kiểm tra xem có đủ nguyên vật liệu còn lại để làm sản phẩm cần thiết không
CREATE FUNCTION dbo.CheckMaterialAvailability (
    @ProductID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @MaterialsNeeded TABLE (
        MaterialID INT,
        QuantityNeeded INT
    );

    -- Retrieve information about the materials needed to produce the product
    INSERT INTO @MaterialsNeeded (MaterialID, QuantityNeeded)
    SELECT MaterialID, QuantityNeeded
    FROM ProductMaterials
    WHERE ProductID = @ProductID;

    DECLARE @MaterialID INT;
    DECLARE @QuantityNeeded INT;
    DECLARE @AvailableQuantity INT;

    DECLARE MaterialCursor CURSOR FOR
    SELECT MaterialID, QuantityNeeded
    FROM @MaterialsNeeded;

    OPEN MaterialCursor;
    FETCH NEXT FROM MaterialCursor INTO @MaterialID, @QuantityNeeded;

    -- Check the availability of sufficient materials
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Retrieve the remaining quantity of the material in stock
        SELECT @AvailableQuantity = Quantity
        FROM Materials
        WHERE MaterialID = @MaterialID;

        -- If the remaining quantity is not enough, return 0
        IF @AvailableQuantity < @QuantityNeeded
        BEGIN
            CLOSE MaterialCursor;
            DEALLOCATE MaterialCursor;
            RETURN 0;
        END;

        FETCH NEXT FROM MaterialCursor INTO @MaterialID, @QuantityNeeded;
    END;

    CLOSE MaterialCursor;
    DEALLOCATE MaterialCursor;

    -- If there are enough materials, return 1
    RETURN 1;
END;
GO




































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

INSERT INTO [employee] ([cccd], [address], [job_type], [date_of_work], [gender], [date_of_birth], [last_name], [middle_name], [first_name]) 
VALUES 
('AB123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2024-04-30 09:00:00', N'MALE', '1980-05-15', N'Nguyễn', N'Văn', N'An'),
('CD987654321', N'456 Đường Lê Lợi, Thành phố Hà Nội', N'Thu Ngân', '2024-04-29 08:30:00', N'FEMALE', '1985-10-20', N'Trần', N'Thị', N'Bích'),
('EF456123789', N'789 Đường Lý Tự Trọng, Thành phố Đà Nẵng', N'Pha chế', '2024-04-28 08:00:00', N'MALE', '1990-03-25', N'Lê', N'Hữu', N'Quốc'),
('GH789456123', N'101 Đường Trần Hưng Đạo, Thành phố Cần Thơ', N'Phục vụ', '2024-04-27 07:30:00', N'FEMALE', '1995-08-10', N'Phạm', N'Thị', N'Hoài'),
('IJ321654987', N'201 Đường Nguyễn Huệ, Thành phố Hải Phòng', N'Bảo vệ', '2024-04-26 07:00:00', N'MALE', '1998-12-05', N'Hoàng', N'Văn', N'Bảo'),
('KL321987321', N'301 Đường Võ Văn Kiệt, Thành phố Bình Dương', N'Thu Ngân', '2024-04-25 06:30:00', N'FEMALE', '1987-02-20', N'Ngô', N'Thị', N'Dung'),
('MN654987321', N'401 Đường Trần Phú, Thành phố Hải Dương', N'Phục vụ', '2024-04-24 06:00:00', N'MALE', '1992-07-15', N'Vũ', N'Đình', N'Anh'),
('OP789321654', N'501 Đường Bà Triệu, Thành phố Huế', N'Phục vụ', '2024-04-23 05:30:00', N'FEMALE', '1996-11-30', N'Đặng', N'Thị', N'Ly'),
('QR987321654', N'601 Đường Phan Đình Phùng, Thành phố Vũng Tàu', N'Pha chế', '2024-04-22 05:00:00', N'MALE', '1989-04-25', N'Trương', N'Văn', N'Tuấn'),
('ST321789654', N'701 Đường Nguyễn Du, Thành phố Nha Trang', N'Bảo vệ', '2024-04-21 04:30:00', N'FEMALE', '1994-09-10', N'Bùi', N'Thị', N'Nga'),
('UV123789654', N'801 Đường Nguyễn Thị Minh Khai, Thành phố Long Xuyên', N'Pha chế', '2024-04-20 04:00:00', N'MALE', '1986-01-20', N'Lý', N'Văn', N'Hải'),
('WX987654321', N'901 Đường Phạm Văn Đồng, Thành phố Thủ Dầu Một', N'Phục vụ', '2024-04-19 03:30:00', N'FEMALE', '1993-06-15', N'Mai', N'Thị', N'Hương'),
('YZ789123654', N'1001 Đường Nguyễn Thái Học, Thành phố Quy Nhơn', N'Phục vụ', '2024-04-18 03:00:00', N'MALE', '1988-11-10', N'Đoàn', N'Văn', N'Thành'),
('AB456987123', N'1101 Đường Lý Thường Kiệt, Thành phố Bắc Ninh', N'Bảo vệ', '2024-04-17 02:30:00', N'FEMALE', '1991-04-05', N'Võ', N'Thị', N'Mỹ'),
('CD654321789', N'1201 Đường Phan Chu Trinh, Thành phố Hòa Bình', N'Pha chế', '2024-04-16 02:00:00', N'MALE', '1984-09-30', N'Đinh', N'Văn', N'Dũng'),
('EF123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2024-04-30 09:00:00', N'MALE', '1981-05-15', N'Nguyễn', N'Văn', N'An'),
('GH987654321', N'456 Đường Lê Lợi, Thành phố Hà Nội', N'Thu Ngân', '2024-04-29 08:30:00', N'FEMALE', '1986-10-20', N'Trần', N'Thị', N'Bích'),
('IJ456123789', N'789 Đường Lý Tự Trọng, Thành phố Đà Nẵng', N'Pha chế', '2024-04-28 08:00:00', N'MALE', '1991-03-25', N'Lê', N'Hữu', N'Quốc'),
('KL789456123', N'101 Đường Trần Hưng Đạo, Thành phố Cần Thơ', N'Phục vụ', '2024-04-27 07:30:00', N'FEMALE', '1997-08-10', N'Phạm', N'Thị', N'Hoài'),
('MN321654987', N'201 Đường Nguyễn Huệ, Thành phố Hải Phòng', N'Bảo vệ', '2024-04-26 07:00:00', N'MALE', '1999-12-05', N'Hoàng', N'Văn', N'Bảo'),
('OP321987321', N'301 Đường Võ Văn Kiệt, Thành phố Bình Dương', N'Thu Ngân', '2024-04-25 06:30:00', N'FEMALE', '1988-02-20', N'Ngô', N'Thị', N'Dung'),
('QR654987321', N'401 Đường Trần Phú, Thành phố Hải Dương', N'Phục vụ', '2024-04-24 06:00:00', N'MALE', '1993-07-15', N'Vũ', N'Đình', N'Anh'),
('ST789321654', N'501 Đường Bà Triệu, Thành phố Huế', N'Phục vụ', '2024-04-23 05:30:00', N'FEMALE', '1997-11-30', N'Đặng', N'Thị', N'Ly'),
('UV987321654', N'601 Đường Phan Đình Phùng, Thành phố Vũng Tàu', N'Pha chế', '2024-04-22 05:00:00', N'MALE', '1990-04-25', N'Trương', N'Văn', N'Tuấn'),
('WX321789654', N'701 Đường Nguyễn Du, Thành phố Nha Trang', N'Bảo vệ', '2024-04-21 04:30:00', N'FEMALE', '1995-09-10', N'Bùi', N'Thị', N'Nga'),
('YZ123789654', N'801 Đường Nguyễn Thị Minh Khai, Thành phố Long Xuyên', N'Pha chế', '2024-04-20 04:00:00', N'MALE', '1987-01-20', N'Lý', N'Văn', N'Hải'),
('AB987654321', N'901 Đường Phạm Văn Đồng, Thành phố Thủ Dầu Một', N'Phục vụ', '2024-04-19 03:30:00', N'FEMALE', '1994-06-15', N'Mai', N'Thị', N'Hương'),
('CD789123654', N'1001 Đường Nguyễn Thái Học, Thành phố Quy Nhơn', N'Phục vụ', '2024-04-18 03:00:00', N'MALE', '1989-11-10', N'Đoàn', N'Văn', N'Thành'),
('EF456987123', N'1101 Đường Lý Thường Kiệt, Thành phố Bắc Ninh', N'Bảo vệ', '2024-04-17 02:30:00', N'FEMALE', '1992-04-05', N'Võ', N'Thị', N'Mỹ'),
('GH654321789', N'1201 Đường Phan Chu Trinh, Thành phố Hòa Bình', N'Pha chế', '2024-04-16 02:00:00', N'MALE', '1985-09-30', N'Đinh', N'Văn', N'Dũng'),
('IJ123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2024-04-30 09:00:00', N'MALE', '1982-05-15', N'Nguyễn', N'Văn', N'An'),
('KL987654321', N'456 Đường Lê Lợi, Thành phố Hà Nội', N'Thu Ngân', '2024-04-29 08:30:00', N'FEMALE', '1987-10-20', N'Trần', N'Thị', N'Bích'),
('MN456123789', N'789 Đường Lý Tự Trọng, Thành phố Đà Nẵng', N'Pha chế', '2024-04-28 08:00:00', N'MALE', '1992-03-25', N'Lê', N'Hữu', N'Quốc'),
('OP789456123', N'101 Đường Trần Hưng Đạo, Thành phố Cần Thơ', N'Phục vụ', '2024-04-27 07:30:00', N'FEMALE', '1998-08-10', N'Phạm', N'Thị', N'Hoài'),
('QR321654987', N'201 Đường Nguyễn Huệ, Thành phố Hải Phòng', N'Bảo vệ', '2024-04-26 07:00:00', N'MALE', '2000-12-05', N'Hoàng', N'Văn', N'Bảo'),
('ST321987321', N'301 Đường Võ Văn Kiệt, Thành phố Bình Dương', N'Thu Ngân', '2024-04-25 06:30:00', N'FEMALE', '1989-02-20', N'Ngô', N'Thị', N'Dung'),
('UV654987321', N'401 Đường Trần Phú, Thành phố Hải Dương', N'Phục vụ', '2024-04-24 06:00:00', N'MALE', '1994-07-15', N'Vũ', N'Đình', N'Anh'),
('WX789321654', N'501 Đường Bà Triệu, Thành phố Huế', N'Phục vụ', '2024-04-23 05:30:00', N'FEMALE', '1998-11-30', N'Đặng', N'Thị', N'Ly'),
('YZ987321654', N'601 Đường Phan Đình Phùng, Thành phố Vũng Tàu', N'Pha chế', '2024-04-22 05:00:00', N'MALE', '1991-04-25', N'Trương', N'Văn', N'Tuấn'),
('AB321789654', N'701 Đường Nguyễn Du, Thành phố Nha Trang', N'Bảo vệ', '2024-04-21 04:30:00', N'FEMALE', '1996-09-10', N'Bùi', N'Thị', N'Nga'),
('CD123789654', N'801 Đường Nguyễn Thị Minh Khai, Thành phố Long Xuyên', N'Pha chế', '2024-04-20 04:00:00', N'MALE', '1988-01-20', N'Lý', N'Văn', N'Hải'),
('EF987654321', N'901 Đường Phạm Văn Đồng, Thành phố Thủ Dầu Một', N'Phục vụ', '2024-04-19 03:30:00', N'FEMALE', '1995-06-15', N'Mai', N'Thị', N'Hương'),
('GH789123654', N'1001 Đường Nguyễn Thái Học, Thành phố Quy Nhơn', N'Phục vụ', '2024-04-18 03:00:00', N'MALE', '1990-11-10', N'Đoàn', N'Văn', N'Thành'),
('IJ456987123', N'1101 Đường Lý Thường Kiệt, Thành phố Bắc Ninh', N'Bảo vệ', '2024-04-17 02:30:00', N'FEMALE', '1993-04-05', N'Võ', N'Thị', N'Mỹ'),
('KL654321789', N'1201 Đường Phan Chu Trinh, Thành phố Hòa Bình', N'Pha chế', '2024-04-16 02:00:00', N'MALE', '1986-09-30', N'Đinh', N'Văn', N'Dũng'),
('MN123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2024-04-30 09:00:00', N'MALE', '1983-05-15', N'Nguyễn', N'Văn', N'An'),
('OP987654321', N'456 Đường Lê Lợi, Thành phố Hà Nội', N'Thu Ngân', '2024-04-29 08:30:00', N'FEMALE', '1988-10-20', N'Trần', N'Thị', N'Bích'),
('QR456123789', N'789 Đường Lý Tự Trọng, Thành phố Đà Nẵng', N'Pha chế', '2024-04-28 08:00:00', N'MALE', '1993-03-25', N'Lê', N'Hữu', N'Quốc'),
('ST789456123', N'101 Đường Trần Hưng Đạo, Thành phố Cần Thơ', N'Phục vụ', '2024-04-27 07:30:00', N'FEMALE', '1999-08-10', N'Phạm', N'Thị', N'Hoài'),
('UV321654987', N'201 Đường Nguyễn Huệ, Thành phố Hải Phòng', N'Bảo vệ', '2024-04-26 07:00:00', N'MALE', '2001-12-05', N'Hoàng', N'Văn', N'Bảo'),
('WX321987321', N'301 Đường Võ Văn Kiệt, Thành phố Bình Dương', N'Thu Ngân', '2024-04-25 06:30:00', N'FEMALE', '1990-02-20', N'Ngô', N'Thị', N'Dung'),
('YZ654987321', N'401 Đường Trần Phú, Thành phố Hải Dương', N'Phục vụ', '2024-04-24 06:00:00', N'MALE', '1995-07-15', N'Vũ', N'Đình', N'Anh'),
('AB789321654', N'501 Đường Bà Triệu, Thành phố Huế', N'Phục vụ', '2024-04-23 05:30:00', N'FEMALE', '1999-11-30', N'Đặng', N'Thị', N'Ly'),
('CD987321654', N'601 Đường Phan Đình Phùng, Thành phố Vũng Tàu', N'Pha chế', '2024-04-22 05:00:00', N'MALE', '1992-04-25', N'Trương', N'Văn', N'Tuấn'),
('EF321789654', N'701 Đường Nguyễn Du, Thành phố Nha Trang', N'Bảo vệ', '2024-04-21 04:30:00', N'FEMALE', '1997-09-10', N'Bùi', N'Thị', N'Nga'),
('GH123789654', N'801 Đường Nguyễn Thị Minh Khai, Thành phố Long Xuyên', N'Pha chế', '2024-04-20 04:00:00', N'MALE', '1989-01-20', N'Lý', N'Văn', N'Hải'),
('IJ987654321', N'901 Đường Phạm Văn Đồng, Thành phố Thủ Dầu Một', N'Phục vụ', '2024-04-19 03:30:00', N'FEMALE', '1996-06-15', N'Mai', N'Thị', N'Hương'),
('KL789321654', N'1001 Đường Nguyễn Thái Học, Thành phố Quy Nhơn', N'Phục vụ', '2024-04-18 03:00:00', N'MALE', '1991-11-10', N'Đoàn', N'Văn', N'Thành'),
('MN321987321', N'1101 Đường Lý Thường Kiệt, Thành phố Bắc Ninh', N'Bảo vệ', '2024-04-17 02:30:00', N'FEMALE', '1994-04-05', N'Võ', N'Thị', N'Mỹ'),
('OP654987321', N'1201 Đường Phan Chu Trinh, Thành phố Hòa Bình', N'Pha chế', '2024-04-16 02:00:00', N'MALE', '1987-09-30', N'Đinh', N'Văn', N'Dũng');

INSERT INTO [employee_dependent] ([ssn], [name], [relationship],[phone_number], [address],[date_of_birth],[gender])
VALUES 
(1, N'Nguyễn Thị Bình', N'Con', '0123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', '1987-09-30','FEMALE'),
(1, N'Nguyễn Bình AN', N'Cha', '0123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', '1987-09-30','MALE'),
(2, N'Nguyễn Văn An', N'Con', '0987654321', N'456 Đường Lê Lợi, Thành phố Hà Nội', '1988-02-22','MALE');


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


-- -- Declare a variable to hold the job type you want to query
-- DECLARE @job_type NVARCHAR(100);
-- SET @job_type = N'Phục vụ'; -- Replace 'YourJobTypeHere' with the actual job type you want to query

-- -- Execute the stored procedure with the specified job type
-- EXEC dbo.proc_GetEmployeeByJobType @job_type;