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
      [insurance] VARCHAR(50) NOT NULL ,
      [month_salary] DECIMAL(10,2) NOT NULL,
      PRIMARY KEY ([ssn]),
      UNIQUE ([insurance]),
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


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'supplier_item')
BEGIN
    CREATE TABLE [supplier_item] (
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
      CONSTRAINT [fk_supply_supplier_item] FOREIGN KEY ([product_name]) REFERENCES [supplier_item] ([product_name]) ON DELETE CASCADE
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
      [phone_number] VARCHAR(50) NULL,
      [date_of_birth] DATE NULL,
      [bonus_point] INT NULL,
      PRIMARY KEY ([id])
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


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'order')
BEGIN
    CREATE TABLE [order] (
      [id] INT NOT NULL IDENTITY(1,1),
      [order_type] NVARCHAR(50) NOT NULL,
      [note] NVARCHAR(500) DEFAULT NULL,
      [employee_ssn] INT NOT NULL,
      [customer_id] INT DEFAULT NULL,
      [promotion_id] INT DEFAULT NULL,
      PRIMARY KEY ([id]),
      CONSTRAINT [fk_order_employee] FOREIGN KEY ([employee_ssn]) REFERENCES [employee] ([ssn]) ON DELETE CASCADE,
      CONSTRAINT [fk_order_customer] FOREIGN KEY ([customer_id]) REFERENCES [customer] ([id]) ON DELETE CASCADE,
      CONSTRAINT [fk_order_promotion] FOREIGN KEY ([promotion_id]) REFERENCES [promotion] ([id]) ON DELETE SET NULL
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
      [payment_method] NVARCHAR(50) NOT NULL CHECK (payment_method IN (N'Tiền mặt', N'Chuyển khoản')),
      [order_id] INT NOT NULL,
      [total_price] DECIMAL(18, 2) NULL,
      PRIMARY KEY ([id]),
      CONSTRAINT [fk_sale_invoice_order] FOREIGN KEY ([order_id]) REFERENCES [order] ([id]) ON DELETE CASCADE
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


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'table')
BEGIN
    CREATE TABLE [table] (
      [id] INT NOT NULL,
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
      [total_price] DECIMAL(10,2) NULL,
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

-- 2. Create procedure to update employee
IF OBJECT_ID('dbo.proc_UpdateEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_UpdateEmployee;
GO

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

-- 3. Create procedure to delete employee
IF OBJECT_ID('dbo.proc_DeleteEmployees', 'P') IS NOT NULL
    DROP PROCEDURE dbo.proc_DeleteEmployees;
GO

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


-- Initialize trigger
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

-- Trigger check discount value of percentage discount
IF OBJECT_ID('dbo.Check_Promotion_Discount', 'TR') IS NOT NULL
    DROP TRIGGER dbo.Check_Promotion_Discount; 
GO

CREATE TRIGGER Check_Promotion_Discount
ON dbo.promotion
AFTER INSERT, UPDATE
AS
BEGIN

    IF EXISTS (SELECT 1 FROM INSERTED WHERE discount_type = 'PERCENT' AND (discount_value <= 0 OR discount_value > 50))
    BEGIN
        RAISERROR ('The discount value for percentage discounts must be within the range of 0 to 50.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- Trigger to update total price in size_order table
IF OBJECT_ID('dbo.Calculate_SubPrice', 'TR') IS NOT NULL
    DROP TRIGGER dbo.Calculate_SubPrice;
GO

CREATE TRIGGER Calculate_SubPrice
ON dbo.size_order
AFTER INSERT, UPDATE
AS
BEGIN
    -- Khai báo biến
    DECLARE @ma_dh INT;
    DECLARE @ma_km INT;
    DECLARE @ten_thuc_uong NVARCHAR(100);
    DECLARE @size NVARCHAR(50);
    DECLARE @quantity INT;
    DECLARE @current_date DATETIME;
    DECLARE @promotion_active BIT;
    DECLARE @discount_type NVARCHAR(50);
    DECLARE @discount_value DECIMAL(10, 2);
    DECLARE @total_price DECIMAL(10, 2);
    
    -- Open cursor
    DECLARE insert_cursor CURSOR FOR
    SELECT size, quantity, order_id, beverage_name
    FROM INSERTED;

    -- Initialize variables
    SET @current_date = GETDATE();
    SET @promotion_active = 0;

    OPEN insert_cursor;
    FETCH NEXT FROM insert_cursor INTO @size, @quantity, @ma_dh, @ten_thuc_uong;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        SET @ma_km = NULL;
        SET @discount_type = NULL;
        SET @discount_value = NULL;

        -- Lấy mã khuyến mãi từ bảng Đơn hàng
        SELECT @ma_km = promotion_id
        FROM [order]
        WHERE id = @ma_dh;

        -- Kiểm tra khuyến mãi có hợp lệ và còn hiệu lực không
        IF EXISTS (
            SELECT 1 FROM promotion p
            JOIN size_promotion sp ON p.id = sp.promotion_id
            WHERE p.id = @ma_km
                AND @current_date BETWEEN p.start_date AND p.end_date
                AND sp.beverage_name = @ten_thuc_uong
                AND sp.size = @size
                AND sp.quantity <= @quantity
        )
        BEGIN
            SET @promotion_active = 1;
            SELECT @discount_type = discount_type, @discount_value = discount_value
            FROM promotion WHERE id = @ma_km;
        END

        -- Tính tổng giá tiền cho mỗi size của thức uống
        SET @total_price = 
            CASE 
                WHEN @promotion_active = 1 AND @discount_type = 'PERCENT' THEN @quantity * (SELECT price FROM size WHERE size = @size AND beverage_name = @ten_thuc_uong) * (1 - @discount_value / 100)
                WHEN @promotion_active = 1 AND @discount_type = 'AMOUNT' THEN @quantity * (SELECT price FROM size WHERE size = @size AND beverage_name = @ten_thuc_uong) - @discount_value
                ELSE @quantity * (SELECT price FROM size WHERE size = @size AND beverage_name = @ten_thuc_uong)
            END;
            
        -- Cập nhật tổng tiền trong bảng 'Bao gồm' dựa trên giá và số lượng
        UPDATE [size_order]
        SET total_price = @total_price
        WHERE order_id = @ma_dh
            AND beverage_name = @ten_thuc_uong
            AND size = @size;

        -- Fetch the next row from the cursor
        FETCH NEXT FROM insert_cursor INTO @size, @quantity, @ma_dh, @ten_thuc_uong;
    END;

    -- Close the cursor
    CLOSE insert_cursor;
    DEALLOCATE insert_cursor;
END;
GO


-- Trigger tính tổng tiền trong hóa đơn và tích điểm cho khách hàng:
IF OBJECT_ID('dbo.Calculate_TotalPrice', 'TR') IS NOT NULL
    DROP TRIGGER dbo.Calculate_TotalPrice;
GO

CREATE TRIGGER Calculate_TotalPrice
ON dbo.sale_invoice
AFTER INSERT
AS
BEGIN

    -- Khai báo biến
    DECLARE @ma_hd INT;
    DECLARE @ma_dh INT;
    DECLARE @ma_kh INT;
    DECLARE @tong_tien_thanh_toan DECIMAL(18, 2);
    DECLARE @diem_tich_luy INT;

    -- Declare cursor
    DECLARE invoice_cursor CURSOR FOR
    SELECT id, order_id
    FROM INSERTED;

    -- Open the cursor
    OPEN invoice_cursor;

    -- Fetch the first row
    FETCH NEXT FROM invoice_cursor INTO @ma_hd, @ma_dh;

    -- Loop through all inserted rows
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Lấy mã khách hàng từ bảng Đơn hàng
        SELECT @ma_kh = customer_id FROM [order] WHERE id = @ma_dh;

        -- Tính toán tổng tiền thanh toán
        SELECT @tong_tien_thanh_toan = SUM(total_price)
        FROM size_order
        WHERE order_id = @ma_dh;

        -- Cập nhật tổng tiền thanh toán trong bảng hóa đơn
        UPDATE sale_invoice
        SET total_price = @tong_tien_thanh_toan
        WHERE id = @ma_hd;

        -- Cập nhật điểm tích lũy chỉ cho khách hàng thành viên (không phải mã mặc định)
        IF @ma_kh <> 0
        BEGIN
            -- Tính toán điểm tích lũy dựa trên tổng tiền (giả sử 1 điểm cho mỗi 10000 đồng chi tiêu)
            SET @diem_tich_luy = @tong_tien_thanh_toan / 10000;

            UPDATE customer
            SET bonus_point = bonus_point + @diem_tich_luy
            WHERE id = @ma_kh;
        END

        -- Fetch the next row
        FETCH NEXT FROM invoice_cursor INTO @ma_hd, @ma_dh;
    END

    -- Close and deallocate the cursor
    CLOSE invoice_cursor;
    DEALLOCATE invoice_cursor;
END;
GO




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


IF OBJECT_ID('dbo.Average_Salary_Emps_As_Job_Type', 'P') IS NOT NULL
    DROP PROCEDURE dbo.Average_Salary_Emps_As_Job_Type;
GO

CREATE PROCEDURE Average_Salary_Emps_As_Job_Type (
    @Nums_of_Emps INT,
    @Type NVARCHAR(50)
)
AS
BEGIN
    IF @Type = 'Full-time'
    BEGIN
        SELECT AVG(fe.month_salary) AS Avg_salary, COUNT(fe.ssn) AS Num_of_Emps, e.job_type
        FROM employee e, full_time_employee fe
        WHERE e.ssn = fe.ssn
        GROUP BY e.job_type
        HAVING COUNT(fe.ssn) > @Nums_of_Emps
        ORDER BY Num_of_Emps;
    END
    ELSE
    BEGIN
        SELECT AVG(pe.hourly_salary) AS Avg_salary, COUNT(pe.ssn) AS Num_of_Emps, e.job_type
        FROM employee e, part_time_employee pe
        WHERE e.ssn = pe.ssn
        GROUP BY e.job_type
        HAVING COUNT(pe.ssn) > @Nums_of_Emps
        ORDER BY Num_of_Emps;
    END
END;
GO


-- Function
IF OBJECT_ID('dbo.CalculateTotalSoldQuantity', 'FN') IS NOT NULL
    DROP FUNCTION dbo.CalculateTotalSoldQuantity;
GO

-- Hàm tính tổng số lượng sản phẩm đã bán của một loại sản phẩm cụ thể trong một khoảng thời gian nhất định:
CREATE FUNCTION CalculateTotalSoldQuantity(
    @beverageName NVARCHAR(50),
    @size NVARCHAR(50),
    @startDate DATE = NULL,
    @endDate DATE = NULL
)
RETURNS INT
AS
BEGIN
    DECLARE @totalSoldQuantity INT = 0;
    DECLARE @calcStartDate DATE;
    DECLARE @calcEndDate DATE;

    -- Calculate start date if NULL
    IF @startDate IS NULL
        SET @calcStartDate = '1900-01-01';
    ELSE
        SET @calcStartDate = @startDate;

    -- Calculate end date if NULL
    IF @endDate IS NULL
        SET @calcEndDate = GETDATE();
    ELSE
        SET @calcEndDate = @endDate;


    -- Sử dụng con trỏ để lặp qua các đơn hàng đã bán
    DECLARE invoiceCursor CURSOR FOR
    SELECT si.[id]
    FROM [sale_invoice] si
    INNER JOIN [order] o ON si.[order_id] = o.[id]
    INNER JOIN [size_order] so ON so.[order_id] = o.[id]
    WHERE so.[beverage_name] = @beverageName AND so.[size] = @size
    AND si.[date] BETWEEN @calcStartDate AND @calcEndDate;

    DECLARE @invoiceId INT;

    OPEN invoiceCursor;
    FETCH NEXT FROM invoiceCursor INTO @invoiceId;

    -- Lặp qua từng đơn hàng đã bán và tính tổng số lượng sản phẩm đã bán
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @orderQuantity INT;

        -- Tính tổng số lượng sản phẩm trong đơn hàng đã bán
        SELECT @orderQuantity = SUM(quantity)
        FROM [size_order]
        WHERE [order_id] = @invoiceId
        AND [beverage_name] = @beverageName
        AND [size] = @size;

        -- Cộng số lượng sản phẩm của đơn hàng vào tổng số lượng đã bán
        SET @totalSoldQuantity = @totalSoldQuantity + @orderQuantity;

        FETCH NEXT FROM invoiceCursor INTO @invoiceId;
    END;

    CLOSE invoiceCursor;
    DEALLOCATE invoiceCursor;

    -- Trả về tổng số lượng sản phẩm đã bán
    RETURN @totalSoldQuantity;
END;
GO

-- Hàm kiểm tra xem có đủ nguyên vật liệu còn lại để làm sản phẩm cần thiết không
IF OBJECT_ID('dbo.CheckItemInStoreAvailability', 'FN') IS NOT NULL
    DROP FUNCTION dbo.CheckItemInStoreAvailability;
GO

CREATE FUNCTION dbo.CheckItemInStoreAvailability (
    @beverage_name NVARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @MaterialsNeeded TABLE (
        product_name NVARCHAR(50),
        quantity INT
    );

    -- Retrieve information about the materials needed to produce the product
    INSERT INTO @MaterialsNeeded (product_name, quantity)
    SELECT product_name, quantity
    FROM size_item_in_store
    WHERE beverage_name = @beverage_name;

    DECLARE @product_name NVARCHAR(50);
    DECLARE @quantity INT;
    DECLARE @AvailableQuantity INT;

    DECLARE MaterialCursor CURSOR FOR
    SELECT product_name, quantity
    FROM @MaterialsNeeded;

    OPEN MaterialCursor;
    FETCH NEXT FROM MaterialCursor INTO @product_name, @quantity;

    -- Check the availability of sufficient materials
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Retrieve the remaining quantity of the material in stock
        SELECT @AvailableQuantity = remaining_quantity
        FROM item_in_store
        WHERE product_name = @product_name;

        -- If the remaining quantity is enough, return 1
        IF @AvailableQuantity >= @quantity
        BEGIN
            CLOSE MaterialCursor;
            DEALLOCATE MaterialCursor;
            RETURN 1;
        END;

        FETCH NEXT FROM MaterialCursor INTO @product_name, @quantity;
    END;

    CLOSE MaterialCursor;
    DEALLOCATE MaterialCursor;

    -- If there are not enough materials, return 0
    RETURN 0;
END;
GO



INSERT INTO [employee] ([cccd], [address], [job_type], [date_of_work], [gender], [date_of_birth], [last_name], [middle_name], [first_name],[super_ssn],[image_url]) 
VALUES 
(N'AB123456789', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', N'Pha chế', '2022-04-30 09:00:00', N'MALE', '1980-05-15', N'Nguyễn', N'Văn', N'An', NULL, 'http://localhost:5000/api/v1/employees/images/1.png'),
(N'CD987654321', N'456 Đường Nguyễn Văn Linh, Thành phố Hồ Chí Minh', N'Phục vụ', '2023-05-01 10:00:00', N'FEMALE', '1990-06-20', N'Lê', N'Thị', N'Bình', 1, 'http://localhost:5000/api/v1/employees/images/11.png'),
(N'EF123456789', N'789 Đường Lê Lợi, Thành phố Hồ Chí Minh', N'Thu ngân', '2021-05-02 11:00:00', N'MALE', '1985-07-25', N'Trần', N'Văn', N'Trung', 2, 'http://localhost:5000/api/v1/employees/images/2.jpeg'),
(N'GH987654321', N'987 Đường Trần Hưng Đạo, Thành phố Hồ Chí Minh', N'Bảo vệ', '2023-05-03 12:00:00', N'FEMALE', '1995-08-30', N'Phạm', N'Thị', N'Hương', 3, 'http://localhost:5000/api/v1/employees/images/12.png'),
(N'IJ123456789', N'654 Đường Nguyễn Huệ, Thành phố Hồ Chí Minh', N'Pha chế', '2022-05-04 13:00:00', N'MALE', '1988-09-10', N'Huỳnh', N'Văn', N'Thành', 1, 'http://localhost:5000/api/v1/employees/images/3.png'),
(N'KL987654321', N'321 Đường Lê Duẩn, Thành phố Hồ Chí Minh', N'Phục vụ', '2023-05-05 14:00:00', N'FEMALE', '1992-10-15', N'Võ', N'Thị', N'Yến', 1, 'http://localhost:5000/api/v1/employees/images/13.png'),
(N'MN123456789', N'987 Đường Nguyễn Thị Minh Khai, Thành phố Hồ Chí Minh', N'Thu ngân', '2019-05-06 15:00:00', N'MALE', '1983-11-20', N'Lý', N'Văn', N'Quân', 4, 'http://localhost:5000/api/v1/employees/images/4.png'),
(N'OP987654321', N'456 Đường Nguyễn Đình Chiểu, Thành phố Hồ Chí Minh', N'Bảo vệ', '2019-05-07 16:00:00', N'FEMALE', '1997-12-25', N'Đặng', N'Thị', N'Thảo', 4, 'http://localhost:5000/api/v1/employees/images/14.png'),
(N'QR123456789', N'123 Đường Nguyễn Văn Thủ, Thành phố Hồ Chí Minh', N'Pha chế', '2020-05-08 17:00:00', N'MALE', '1986-01-30', N'Hoàng', N'Văn', N'Nam', 5, 'http://localhost:5000/api/v1/employees/images/5.png'),
(N'ST987654321', N'789 Đường Lê Lai, Thành phố Hồ Chí Minh', N'Phục vụ', '2021-05-09 18:00:00', N'FEMALE', '1993-02-05', N'Ngô', N'Thị', N'Thùy', 5, 'http://localhost:5000/api/v1/employees/images/15.png'),
(N'UV123456789', N'987 Đường Trần Phú, Thành phố Hồ Chí Minh', N'Thu ngân', '2022-05-10 19:00:00', N'MALE', '1989-03-10', N'Đỗ', N'Văn', N'Đạt', 3, 'http://localhost:5000/api/v1/employees/images/6.png'),
(N'WX987654321', N'654 Đường Nguyễn Văn Cừ, Thành phố Hồ Chí Minh', N'Bảo vệ', '2021-05-11 20:00:00', N'FEMALE', '1994-04-15', N'Vương', N'Thị', N'Trinh', 6, 'http://localhost:5000/api/v1/employees/images/16.png'),
(N'YZ123456789', N'321 Đường Lê Thánh Tôn, Thành phố Hồ Chí Minh', N'Pha chế', '2010-05-12 21:00:00', N'MALE', '1987-05-20', N'Trương', N'Văn', N'Quốc', 7, 'http://localhost:5000/api/v1/employees/images/7.png'),
(N'AB987654321', N'123 Đường Nguyễn Văn Linh, Thành phố Hồ Chí Minh', N'Phục vụ', '2015-05-13 22:00:00', N'FEMALE', '1991-06-25', N'Đinh', N'Thị', N'Thảo', 7, 'http://localhost:5000/api/v1/employees/images/17.png'),
(N'CD123456789', N'456 Đường Trần Hưng Đạo, Thành phố Hồ Chí Minh', N'Thu ngân', '2015-05-14 23:00:00', N'MALE', '1984-07-30', N'Lê', N'Văn', N'Thành', 4, 'http://localhost:5000/api/v1/employees/images/8.png'),
(N'EF987654321', N'789 Đường Nguyễn Huệ, Thành phố Hồ Chí Minh', N'Bảo vệ', '2017-05-15 00:00:00', N'FEMALE', '1996-08-05', N'Phan', N'Thị', N'Hương', 3, 'http://localhost:5000/api/v1/employees/images/18.png'),
(N'GH123456789', N'987 Đường Lê Duẩn, Thành phố Hồ Chí Minh', N'Pha chế', '2018-05-16 01:00:00', N'MALE', '1981-09-10', N'Hồ', N'Văn', N'Thành', 6, 'http://localhost:5000/api/v1/employees/images/9.png'),
(N'IJ987654321', N'654 Đường Nguyễn Thị Minh Khai, Thành phố Hồ Chí Minh', N'Phục vụ', '2020-05-17 02:00:00', N'FEMALE', '1990-10-15', N'Vũ', N'Thị', N'Yến', 6, 'http://localhost:5000/api/v1/employees/images/19.png'),
(N'KL123456789', N'321 Đường Nguyễn Đình Chiểu, Thành phố Hồ Chí Minh', N'Thu ngân', '2017-05-18 03:00:00', N'MALE', '1985-11-20', N'Nguyễn', N'Văn', N'Quân', 6, 'http://localhost:5000/api/v1/employees/images/10.png'),
(N'MN987654321', N'987 Đường Nguyễn Văn Thủ, Thành phố Hồ Chí Minh', N'Bảo vệ', '2016-05-19 04:00:00', N'FEMALE', '1999-12-25', N'Lý', N'Thị', N'Thảo', 7, 'http://localhost:5000/api/v1/employees/images/20.png');


INSERT INTO [employee_phone_number] ([ssn], [phone_number])
VALUES 
(1, '0987654321'),
(1, '0999999999'),
(2, '0965483957'),
(3, '0946573847'),
(3, '0987272731'),
(4, '0987654321'),
(5, '0999999999'),
(5, '0909090090'),
(6, '0965483957'),
(7, '0946573847'),
(8, '0987654321'),
(9, '0999999999'),
(10, '0965483957'),
(10, '0965231234'),
(10, '0912381237'),
(11, '0946573847'),
(12, '0987654321'),
(13, '0999999999'),
(14, '0965483957'),
(15, '0946573847'),
(16, '0987654321'),
(17, '0999999999'),
(18, '0965483957'),
(19, '0946573847'),
(20, '0987654321');


INSERT INTO [full_time_employee] ([ssn], [insurance], [month_salary])
VALUES
(1, '123456789', 7000000),
(2, '234567890', 6000000),
(3, '345678901', 8000000),
(9, '901234567', 7000000),
(10, '012345678', 7500000),
(11, '123416789', 8000000),
(12, '234467890', 6000000),
(13, '342678901', 10000000),
(15, '567890123', 9000000),
(17, '789012345', 9000000),
(18, '890123456', 7000000),
(19, '901334567', 7000000);


INSERT INTO [part_time_employee] ([ssn], [hourly_salary])
VALUES
(4, 18000),
(5, 20000),
(6, 17000),
(7, 15000),
(8, 18000),
(14, 17000),
(16, 17000),
(20, 18000);


INSERT INTO [part_time_employee_works] ([ssn], [date], [shift])
VALUES
(4, '2022-05-01', '7:00 AM - 12:00 AM'),
(4, '2022-05-02', '12:00 AM - 17:00 PM'),
(4, '2022-05-03', '7:00 AM - 12:00 AM'),
(5, '2022-05-01', '7:00 AM - 12:00 AM'),
(5, '2022-05-02', '17:00 PM - 22:00 PM'),
(5, '2022-05-03', '7:00 AM - 12:00 AM'),
(6, '2022-05-01', '12:00 AM - 17:00 PM'),
(6, '2022-05-02', '17:00 PM - 22:00 PM'),
(6, '2022-05-03', '7:00 AM - 12:00 AM'),
(7, '2022-05-01', '7:00 AM - 12:00 AM'),
(7, '2022-05-02', '17:00 PM - 22:00 PM'),
(7, '2022-05-03', '7:00 AM - 12:00 AM'),
(8, '2022-05-01', '7:00 AM - 12:00 AM'),
(8, '2022-05-02', '17:00 PM - 22:00 PM'),
(8, '2022-05-03', '7:00 AM - 12:00 AM'),
(14, '2022-05-01', '7:00 AM - 12:00 AM'),
(14, '2022-05-02', '12:00 AM - 17:00 PM'),
(14, '2022-05-03', '7:00 AM - 12:00 AM'),
(16, '2022-05-01', '17:00 PM - 22:00 PM'),
(16, '2022-05-02', '7:00 AM - 12:00 AM'),
(16, '2022-05-03', '12:00 AM - 17:00 PM'),
(20, '2022-05-01', '7:00 AM - 12:00 AM'),
(20, '2022-05-02', '17:00 PM - 22:00 PM'),
(20, '2022-05-03', '7:00 AM - 12:00 AM');


INSERT INTO [employee_dependent] ([ssn], [name], [relationship], [phone_number], [address], [date_of_birth], [gender])
VALUES 
(1, N'Nguyễn Thị Bình', N'Con', '0987654321', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', '2010-05-15', N'FEMALE'),
(1, N'Nguyễn Trần An Nhiên', N'Con', '0987624321', N'123 Đường Mê Linh, Thành phố Hồ Chí Minh', '2001-09-08', N'MALE'),
(2, N'Trần Văn Nam', N'Con', '0987654322', N'456 Đường Lê Lợi, Thành phố Hà Nội', '2008-07-20', N'MALE'),
(2, N'Nguyễn Thị Yến', N'Con', '0922654321', N'456 Đường Lê Lợi, Thành phố Hà Nội', '2004-05-17', N'FEMALE'),
(3, N'Phạm Thị Hương', N'Vợ', '0987654323', N'789 Đường Phan Xích Long, Thành phố Đà Nẵng', '1985-10-10', N'FEMALE'),
(4, N'Lê Tuấn Anh', N'Con', '0987654324', N'987 Đường Hùng Vương, Thành phố Cần Thơ', '2012-12-25', N'MALE'),
(5, N'Vũ Thị Hương', N'Con', '0987654325', N'321 Đường Lê Duẩn, Thành phố Hải Phòng', '2015-03-05', N'FEMALE'),
(6, N'Dương Văn Điệp', N'Con', '0987654326', N'654 Đường Nguyễn Huệ, Thành phố Đà Lạt', '2007-06-15', N'MALE'),
(7, N'Nguyễn Thị Ly', N'Con', '0987654327', N'987 Đường Trần Hưng Đạo, Thành phố Vũng Tàu', '2000-09-20', N'FEMALE'),
(8, N'Trần Hữu Nam', N'Con', '0987654328', N'852 Đường Lý Tự Trọng, Thành phố Nha Trang', '1998-11-30', N'MALE'),
(9, N'Hoàng Thị Hằng', N'Con', '0987654329', N'741 Đường Nguyễn Du, Thành phố Hội An', '1997-04-10', N'FEMALE'),
(10, N'Đặng Văn Thu', N'Con', '0987654330', N'963 Đường Trần Phú, Thành phố Phan Thiết', '1996-08-25', N'MALE'),
(11, N'Lý Thị Mỹ', N'Con', '0987654331', N'159 Đường Lý Thường Kiệt, Thành phố Huế', '1994-01-05', N'FEMALE'),
(12, N'Ngô Hữu Quân', N'Con', '0987654332', N'357 Đường Nguyễn Công Trứ, Thành phố Quy Nhơn', '1993-05-20', N'MALE'),
(13, N'Ma Thị Hoa', N'Con', '0987654333', N'258 Đường Phạm Ngũ Lão, Thành phố Tam Kỳ', '1992-07-15', N'FEMALE'),
(14, N'Lê Văn An', N'Con', '0987654334', N'852 Đường Hồ Xuân Hương, Thành phố Buôn Ma Thuột', '1991-09-30', N'MALE'),
(15, N'Phan Hữu Hoàng', N'Con', '0987654335', N'741 Đường Lê Hồng Phong, Thành phố Vĩnh Yên', '1990-03-10', N'MALE');


INSERT INTO [supplier_invoice] ([date], [time])
VALUES
('2022-05-01', '08:00:00'),
('2022-05-02', '09:00:00'),
('2022-05-03', '10:00:00'),
('2022-05-04', '11:00:00'),
('2022-05-05', '12:00:00'),
('2022-05-06', '13:00:00'),
('2022-05-07', '14:00:00'),
('2022-05-08', '15:00:00'),
('2022-05-09', '16:00:00'),
('2022-05-10', '17:00:00'),
('2022-05-11', '18:00:00'),
('2022-05-12', '19:00:00'),
('2022-05-13', '20:00:00'),
('2022-05-14', '21:00:00'),
('2022-05-15', '22:00:00'),
('2022-05-16', '23:00:00'),
('2022-05-17', '00:00:00'),
('2022-05-18', '01:00:00'),
('2022-05-19', '02:00:00'),
('2022-05-20', '03:00:00');

INSERT INTO [supplier] ([supplier_name])
VALUES
(N'Nhà cung cấp A'),
(N'Nhà cung cấp B'),
(N'Nhà cung cấp C'),
(N'Nhà cung cấp D'),
(N'Nhà cung cấp E'),
(N'Nhà cung cấp F'),
(N'Nhà cung cấp G'),
(N'Nhà cung cấp H'),
(N'Nhà cung cấp I'),
(N'Nhà cung cấp J'),
(N'Nhà cung cấp K'),
(N'Nhà cung cấp L'),
(N'Nhà cung cấp M'),
(N'Nhà cung cấp N'),
(N'Nhà cung cấp P');


INSERT INTO [supplier_item] ([product_name], [unit], [price])
VALUES
(N'Cam', 'kg', 10000),            
(N'Dừa', N'quả', 8000),           
(N'Chuối', 'kg', 15000),          
(N'Dâu', 'kg', 120000),            
(N'Xoài', 'kg', 20000),           
(N'Dưa hấu', 'kg', 35000),        
(N'Lê', 'kg', 50000),             
(N'Nho', 'kg', 200000),            
(N'Dừa nước', 'kg', 150000),      
(N'Lựu', 'kg', 8000),           
(N'Bơ', 'kg', 70000),               
(N'Dưa lưới', 'kg', 100000),      
(N'Chanh', 'kg', 50000),          
(N'Táo', 'kg', 90000),            
(N'Dừa xiêm', N'quả', 30000),       
(N'Nho khô', 'kg', 450000),        
(N'Mơ', 'kg', 100000),                  
(N'Mận', 'kg', 250000),
(N'Cà phê', 'kg', 300000);    


INSERT INTO [supply] ([quantity], [supplier_name], [supplier_invoice_id], [product_name])
VALUES
(100, N'Nhà cung cấp A', 1, N'Cam'),
(200, N'Nhà cung cấp B', 2, N'Dừa'),
(150, N'Nhà cung cấp C', 3, N'Chuối'),
(300, N'Nhà cung cấp D', 4, N'Dâu'),
(250, N'Nhà cung cấp E', 5, N'Xoài'),
(180, N'Nhà cung cấp F', 6, N'Dưa hấu'),
(220, N'Nhà cung cấp G', 7, N'Lê'),
(270, N'Nhà cung cấp H', 8, N'Nho'),
(150, N'Nhà cung cấp I', 9, N'Dừa nước'),
(200, N'Nhà cung cấp J', 10, N'Lựu'),
(250, N'Nhà cung cấp K', 11, N'Bơ'),
(180, N'Nhà cung cấp M', 13, N'Dưa lưới'),
(220, N'Nhà cung cấp N', 14, N'Chanh'),
(270, N'Nhà cung cấp P', 15, N'Táo'),
(150, N'Nhà cung cấp A', 16, N'Dừa xiêm'),
(200, N'Nhà cung cấp B', 17, N'Nho khô'),
(250, N'Nhà cung cấp C', 18, N'Mơ'),
(220, N'Nhà cung cấp D', 19, N'Mận'),
(220, N'Nhà cung cấp F', 20, N'Cà phê');

INSERT INTO [employee_supplier_invoice] ([ssn], [supplier_invoice_id])
VALUES
(12, 1),
(13, 2),
(14, 3),
(15, 4),
(12, 5),
(13, 6),
(14, 7),
(15, 8),
(12, 9),
(13, 10),
(14, 11),
(15, 12),
(12, 13),
(13, 14),
(2, 15),
(3, 16),
(4, 17),
(5, 18),
(6, 19),
(7, 20),
(15, 16),
(12, 17),
(13, 18),
(14, 19),
(15, 20),
(14, 15);


INSERT INTO [item_in_store] ([product_name], [unit], [remaining_quantity], [supplier_invoice_id])
VALUES
(N'Cam', 'kg', 50, 1),
(N'Dừa', N'quả', 60, 2),
(N'Chuối', 'kg', 40, 3),
(N'Dâu', 'kg', 35, 4),
(N'Xoài', 'kg', 50, 5),
(N'Dưa hấu', 'kg', 47, 6),
(N'Lê', 'kg', 10, 7),
(N'Nho', 'kg', 45, 8),
(N'Dừa nước', 'kg', 64, 9),
(N'Lựu', 'kg', 38, 10),
(N'Bơ', 'kg', 100, 11),
(N'Dưa lưới', 'kg', 58, 13),
(N'Chanh', 'kg', 20, 14),
(N'Táo', 'kg', 70, 15),
(N'Dừa xiêm', N'quả', 60, 16),
(N'Nho khô', 'kg', 57, 17),
(N'Mơ', 'kg', 55, 18),
(N'Mận', 'kg', 65, 19),
(N'Cà phê', 'kg', 48, 20);


INSERT INTO [beverage] ([beverage_name], [image_url])
VALUES
(N'Cà phê sữa', 'http://localhost:5000/api/v1/products/images/1.jpeg'),
(N'Cà phê đen', 'http://localhost:5000/api/v1/products/images/2.jpeg'),
(N'Nước cam', 'http://localhost:5000/api/v1/products/images/3.jpeg'),
(N'Nước dừa', 'http://localhost:5000/api/v1/products/images/4.jpeg'),
(N'Nước chanh', 'http://localhost:5000/api/v1/products/images/5.jpeg'),
(N'Sinh tố dâu', 'http://localhost:5000/api/v1/products/images/6.jpeg'),
(N'Nước ép lựu', 'http://localhost:5000/api/v1/products/images/7.jpeg'),
(N'Sinh tố bơ', 'http://localhost:5000/api/v1/products/images/8.jpeg'),
(N'Sinh tố chuối', 'http://localhost:5000/api/v1/products/images/9.jpeg'),
(N'Sinh tố xoài', 'http://localhost:5000/api/v1/products/images/10.jpeg'),
(N'Nước ép dưa hấu', 'http://localhost:5000/api/v1/products/images/11.jpeg'),
(N'Sinh tố nho', 'http://localhost:5000/api/v1/products/images/12.jpeg'),
(N'Nước ép táo', 'http://localhost:5000/api/v1/products/images/13.jpeg'),
(N'Nước ép lê', 'http://localhost:5000/api/v1/products/images/14.jpeg'),
(N'Nước ép mơ', 'http://localhost:5000/api/v1/products/images/15.jpeg'),
(N'Sinh tố mận', 'http://localhost:5000/api/v1/products/images/16.jpeg'),
(N'Sinh tố dừa xiêm', 'http://localhost:5000/api/v1/products/images/17.jpeg'),
(N'Sinh tố nho khô', 'http://localhost:5000/api/v1/products/images/18.jpeg'),
(N'Sinh tố thập cẩm', 'http://localhost:5000/api/v1/products/images/19.jpeg'),
(N'Nước ép thập cẩm', 'http://localhost:5000/api/v1/products/images/20.jpeg');


INSERT INTO [size] ([size], [price], [beverage_name])
VALUES
(N'Lớn', 30000, N'Cà phê sữa'),
(N'Vừa', 25000, N'Cà phê sữa'),
(N'Nhỏ', 20000, N'Cà phê sữa'),
(N'Lớn', 20000, N'Cà phê đen'),
(N'Vừa', 15000, N'Cà phê đen'),
(N'Nhỏ', 10000, N'Cà phê đen'),
(N'Lớn', 15000, N'Nước cam'),
(N'Vừa', 12000, N'Nước cam'),
(N'Nhỏ', 10000, N'Nước cam'),
(N'Lớn', 20000, N'Nước dừa'),
(N'Vừa', 15000, N'Nước dừa'),
(N'Nhỏ', 10000, N'Nước dừa'),
(N'Lớn', 15000, N'Nước chanh'),
(N'Vừa', 12000, N'Nước chanh'),
(N'Nhỏ', 10000, N'Nước chanh'),
(N'Lớn', 25000, N'Sinh tố dâu'),
(N'Vừa', 20000, N'Sinh tố dâu'),
(N'Nhỏ', 15000, N'Sinh tố dâu'),
(N'Lớn', 35000, N'Nước ép lựu'),
(N'Vừa', 30000, N'Nước ép lựu'),
(N'Nhỏ', 25000, N'Nước ép lựu'),
(N'Lớn', 50000, N'Sinh tố bơ'),
(N'Vừa', 45000, N'Sinh tố bơ'),
(N'Nhỏ', 40000, N'Sinh tố bơ'),
(N'Lớn', 20000, N'Sinh tố chuối'),
(N'Vừa', 15000, N'Sinh tố chuối'),
(N'Nhỏ', 10000, N'Sinh tố chuối'),
(N'Lớn', 30000, N'Sinh tố xoài'),
(N'Vừa', 25000, N'Sinh tố xoài'),
(N'Nhỏ', 20000, N'Sinh tố xoài'),
(N'Lớn', 35000, N'Nước ép dưa hấu'),
(N'Vừa', 30000, N'Nước ép dưa hấu'),
(N'Nhỏ', 25000, N'Nước ép dưa hấu'),
(N'Lớn', 50000, N'Sinh tố nho'),
(N'Vừa', 45000, N'Sinh tố nho'),
(N'Nhỏ', 40000, N'Sinh tố nho'),
(N'Lớn', 20000, N'Nước ép táo'),
(N'Vừa', 15000, N'Nước ép táo'),
(N'Nhỏ', 10000, N'Nước ép táo'),
(N'Lớn', 25000, N'Nước ép lê'),
(N'Vừa', 20000, N'Nước ép lê'),
(N'Nhỏ', 15000, N'Nước ép lê'),
(N'Lớn', 30000, N'Nước ép mơ'),
(N'Vừa', 25000, N'Nước ép mơ'),
(N'Nhỏ', 20000, N'Nước ép mơ'),
(N'Lớn', 20000, N'Sinh tố mận'),
(N'Vừa', 15000, N'Sinh tố mận'),
(N'Nhỏ', 10000, N'Sinh tố mận'),
(N'Lớn', 30000, N'Sinh tố dừa xiêm'),
(N'Vừa', 25000, N'Sinh tố dừa xiêm'),
(N'Nhỏ', 20000, N'Sinh tố dừa xiêm'),
(N'Lớn', 45000, N'Sinh tố nho khô'),
(N'Vừa', 40000, N'Sinh tố nho khô'),
(N'Nhỏ', 35000, N'Sinh tố nho khô'),
(N'Lớn', 50000, N'Sinh tố thập cẩm'),
(N'Vừa', 45000, N'Sinh tố thập cẩm'),
(N'Nhỏ', 40000, N'Sinh tố thập cẩm'),
(N'Lớn', 35000, N'Nước ép thập cẩm'),
(N'Vừa', 30000, N'Nước ép thập cẩm'),
(N'Nhỏ', 25000, N'Nước ép thập cẩm');

INSERT INTO [size_item_in_store] ([product_name], [size], [quantity], [beverage_name])
VALUES
(N'Cam', N'Lớn', 5, N'Nước cam'),
(N'Cam', N'Vừa', 3, N'Nước cam'),
(N'Cam', N'Nhỏ', 2, N'Nước cam'),
(N'Dừa', N'Lớn', 5, N'Nước dừa'),
(N'Dừa', N'Vừa', 3, N'Nước dừa'),
(N'Dừa', N'Nhỏ', 2, N'Nước dừa'),
(N'Chuối', N'Lớn', 3, N'Sinh tố chuối'),
(N'Chuối', N'Vừa', 2, N'Sinh tố chuối'),
(N'Chuối', N'Nhỏ', 1, N'Sinh tố chuối'),
(N'Dâu', N'Lớn', 3, N'Sinh tố dâu'),
(N'Dâu', N'Vừa', 2, N'Sinh tố dâu'),
(N'Dâu', N'Nhỏ', 1, N'Sinh tố dâu'),
(N'Xoài', N'Lớn', 4, N'Sinh tố xoài'),
(N'Xoài', N'Vừa', 2, N'Sinh tố xoài'),
(N'Xoài', N'Nhỏ', 1, N'Sinh tố xoài'),
(N'Dưa hấu', N'Lớn', 5, N'Nước ép dưa hấu'),
(N'Dưa hấu', N'Vừa', 4, N'Nước ép dưa hấu'),
(N'Dưa hấu', N'Nhỏ', 3, N'Nước ép dưa hấu'),
(N'Lê', N'Lớn', 5, N'Nước ép lê'),
(N'Lê', N'Vừa', 3, N'Nước ép lê'),
(N'Lê', N'Nhỏ', 2, N'Nước ép lê'),
(N'Nho', N'Lớn', 3, N'Sinh tố nho'),
(N'Nho', N'Vừa', 2, N'Sinh tố nho'),
(N'Nho', N'Nhỏ', 1, N'Sinh tố nho'),
(N'Dừa nước', N'Lớn', 5, N'Nước dừa'),
(N'Dừa nước', N'Vừa', 4, N'Nước dừa'),
(N'Dừa nước', N'Nhỏ', 3, N'Nước dừa'),
(N'Lựu', N'Lớn', 5, N'Nước ép lựu'),
(N'Lựu', N'Vừa', 3, N'Nước ép lựu'),
(N'Lựu', N'Nhỏ', 2, N'Nước ép lựu'),
(N'Bơ', N'Lớn', 5, N'Sinh tố bơ'),
(N'Bơ', N'Vừa', 3, N'Sinh tố bơ'),
(N'Bơ', N'Nhỏ', 2, N'Sinh tố bơ'),
(N'Chanh', N'Lớn', 3, N'Nước chanh'),
(N'Chanh', N'Vừa', 2, N'Nước chanh'),
(N'Chanh', N'Nhỏ', 1, N'Nước chanh'),
(N'Táo', N'Lớn', 5, N'Nước ép táo'),
(N'Táo', N'Vừa', 3, N'Nước ép táo'),
(N'Táo', N'Nhỏ', 2, N'Nước ép táo'),
(N'Dừa xiêm', N'Lớn', 5, N'Sinh tố dừa xiêm'),
(N'Dừa xiêm', N'Vừa', 4, N'Sinh tố dừa xiêm'),
(N'Dừa xiêm', N'Nhỏ', 3, N'Sinh tố dừa xiêm'),
(N'Mơ', N'Lớn', 5, N'Nước ép mơ'),
(N'Mơ', N'Vừa', 3, N'Nước ép mơ'),
(N'Mơ', N'Nhỏ', 2, N'Nước ép mơ'),
(N'Mận', N'Lớn', 3, N'Sinh tố mận'),
(N'Mận', N'Vừa', 2, N'Sinh tố mận'),
(N'Mận', N'Nhỏ', 1, N'Sinh tố mận'),
(N'Cà phê', N'Lớn', 4, N'Cà phê sữa'),
(N'Cà phê', N'Vừa', 3, N'Cà phê sữa'),
(N'Cà phê', N'Nhỏ', 2, N'Cà phê sữa'),
(N'Cà phê', N'Lớn', 3, N'Cà phê đen'),
(N'Cà phê', N'Vừa', 2, N'Cà phê đen'),
(N'Cà phê', N'Nhỏ', 1, N'Cà phê đen');


SET IDENTITY_INSERT [customer] ON;

-- Insert the first record with id = 0
INSERT INTO [customer] ([id], [name], [phone_number], [date_of_birth])
VALUES (0, N'Khách vãng lai', NULL, NULL);

-- Disable identity insert
SET IDENTITY_INSERT [customer] OFF;

INSERT INTO [customer]  ([name], [phone_number], [date_of_birth],[bonus_point])
VALUES
(N'Nguyễn Văn An', '0987654321', '1990-05-15',1),
(N'Trần Thị Bình', '0987654322', '1992-07-20',3),
(N'Phạm Văn Cường', '0987654323', '1995-10-10',4),
(N'Lê Thị Dung', '0987654324', '1998-12-25',1),
(N'Vũ Thị Hương', '0987654325', '2000-03-05',10),
(N'Dương Văn Điệp', '0987654326', '2002-06-15',6),
(N'Nguyễn Thị Ly', '0987654327', '2005-09-20',3),
(N'Trần Hữu Nam', '0987654328', '2008-11-30',5),
(N'Hoàng Thị Hằng', '0987654329', '2010-04-10',6),
(N'Đặng Văn Thu', '0987654330', '2012-08-25',5),
(N'Lý Thị Mỹ', '0987654331', '2014-01-05',4),
(N'Ngô Hữu Quân', '0987654332', '2016-05-20',4),
(N'Ma Thị Hoa', '0987654333', '2018-07-15',3),
(N'Lê Văn An', '0987654334', '2020-09-30',7),
(N'Phan Hữu Hoàng', '0987654335', '2022-03-10',1);


INSERT INTO [promotion] ([promotion_name], [start_date], [end_date], [discount_type], [discount_value])
VALUES
(N'Khuyến mãi 1', '2024-05-01', '2024-05-30', N'PERCENT', 10),
(N'Khuyến mãi 2', '2024-05-01', '2024-05-30', N'AMOUNT', 30000),
(N'Khuyến mãi 3', '2024-05-01', '2024-05-30', N'PERCENT', 20),
(N'Khuyến mãi 4', '2024-05-01', '2024-05-30', N'AMOUNT', 20000),
(N'Khuyến mãi 5', '2024-05-01', '2024-05-30', N'PERCENT', 30),
(N'Khuyến mãi 6', '2024-05-01', '2024-05-30', N'AMOUNT', 70000),
(N'Khuyến mãi 7', '2024-05-01', '2024-05-30', N'PERCENT', 40),
(N'Khuyến mãi 8', '2024-05-01', '2024-05-30', N'AMOUNT', 80000),
(N'Khuyến mãi 9', '2024-05-01', '2024-05-30', N'PERCENT', 50),
(N'Khuyến mãi 10', '2024-05-01', '2024-05-30', N'AMOUNT', 100000);


INSERT INTO [size_promotion] ([size], [beverage_name], [promotion_id], [quantity])
VALUES
(N'Lớn', N'Cà phê sữa', 1, 2),
(N'Lớn', N'Sinh tố dừa xiêm', 1, 4),
(N'Vừa', N'Cà phê đen', 2, 4),
(N'Vừa', N'Sinh tố nho khô', 2, 5),
(N'Nhỏ', N'Nước cam', 3, 2),
(N'Nhỏ', N'Sinh tố mận', 3, 3),
(N'Lớn', N'Nước dừa', 4, 2),
(N'Lớn', N'Sinh tố thập cẩm', 4, 1),
(N'Vừa', N'Nước chanh', 5, 2),
(N'Vừa', N'Nước ép lựu', 6, 3),
(N'Nhỏ', N'Sinh tố bơ', 7, 5),
(N'Nhỏ', N'Sinh tố chuối', 8, 10),
(N'Lớn', N'Sinh tố xoài', 9, 7),
(N'Lớn', N'Nước ép dưa hấu', 10, 10);


INSERT INTO [order] ([order_type], [note], [employee_ssn], [customer_id], [promotion_id])
VALUES
(N'Tại chỗ', N'Không đường', 1, 1, 1),
(N'Mang về', N'Ít đá', 2, 2, 2),
(N'Tại chỗ', N'Nhiều đường', 3, 3, 3),
(N'Mang về', N'Nhiều đá', 4, 4, 4),
(N'Tại chỗ', N'Không đường', 5, 5, 5),
(N'Mang về', N'Ít đá', 6, 6, 6),
(N'Tại chỗ', N'Nhiều đường', 7, 7, 7),
(N'Mang về', N'Nhiều đá', 8, 8, 8),
(N'Tại chỗ', N'Không đường', 9, 9, 9),
(N'Mang về', N'Ít đá', 10, 10, 10),
(N'Tại chỗ', N'Nhiều đường', 11, 11, NULL),
(N'Mang về', N'Nhiều đá', 12, 12, NULL),
(N'Tại chỗ', N'Không đường', 13, 13, NULL),
(N'Mang về', N'Ít đá', 14, 14, NULL),
(N'Tại chỗ', N'Nhiều đường', 15, 15, NULL),
(N'Mang về', N'Nhiều đá', 16, 0, NULL),
(N'Tại chỗ', N'Không đường', 17, 0, NULL),
(N'Mang về', N'Ít đá', 18, 0, NULL),
(N'Tại chỗ', N'Nhiều đường', 19, 0, NULL),
(N'Mang về', N'Nhiều đá', 20, 0, NULL);


INSERT INTO [customer_order] ([customer_id], [order_id], [comment])
VALUES
(1, 1, N'Nước rất ngon'),
(2, 2, N'Sẽ ủng hộ quán'),
(3, 3, N'Đường hơi ít'),
(4, 4, N'Đường hơi nhiều'),
(5, 5, N'Đá hơi ít'),
(6, 6, N'Nước rất ngon'),
(7, 7, N'Đá hơi nhiều'),
(8, 8, N'Đường hơi ít'),
(9, 9, N'Đường hơi nhiều'),
(10, 10, N'Đá hơi ít'),
(11, 11, N'Nước rất ngon'),
(12, 12, N'Đá hơi nhiều'),
(13, 13, N'Đường hơi ít'),
(14, 14, N'Đường hơi nhiều'),
(15, 15, N'Đá hơi ít'),
(0, 17, N'Đá hơi nhiều'),
(0, 18, N'Đường hơi ít'),
(0, 19, N'Đường hơi nhiều'),
(0, 20, N'Đá hơi ít');


INSERT INTO [size_order] ([size], [quantity], [order_id], [beverage_name])
VALUES
(N'Lớn', 2, 1, N'Cà phê sữa'),
(N'Lớn', 4, 1, N'Sinh tố dừa xiêm'),
(N'Vừa', 4, 2, N'Cà phê đen'),
(N'Vừa', 5, 2, N'Sinh tố nho khô'),
(N'Nhỏ', 2, 3, N'Nước cam'),
(N'Nhỏ', 3, 3, N'Sinh tố mận'),
(N'Lớn', 2, 4, N'Nước dừa'),
(N'Lớn', 1, 4, N'Sinh tố thập cẩm'),
(N'Vừa', 7, 5, N'Nước chanh'),
(N'Vừa', 3, 6, N'Nước ép lựu'),
(N'Nhỏ', 5, 7, N'Sinh tố bơ'),
(N'Nhỏ', 3, 8, N'Sinh tố chuối'),
(N'Lớn', 7, 9, N'Sinh tố xoài'),
(N'Lớn', 10, 10, N'Nước ép dưa hấu'),
(N'Vừa', 2, 11, N'Sinh tố nho'),
(N'Vừa', 3, 12, N'Nước ép táo'),
(N'Nhỏ', 1, 13, N'Nước ép lê'),
(N'Nhỏ', 2, 14, N'Nước ép mơ'),
(N'Lớn', 2, 14, N'Sinh tố mận'),
(N'Lớn', 3, 15, N'Nước ép lựu'),
(N'Vừa', 4, 16, N'Sinh tố dâu'),
(N'Nhỏ', 5, 17, N'Nước cam'),
(N'Lớn', 6, 18, N'Nước dừa'),
(N'Vừa', 5, 19, N'Nước chanh'),
(N'Nhỏ', 2, 20, N'Cà phê sữa');


INSERT INTO [sale_invoice] ([date], [time], [payment_method], [order_id])
VALUES
(N'2024-05-01', '08:00:00', N'Tiền mặt', 1),
(N'2024-05-02', '09:00:00', N'Tiền mặt', 2),
(N'2024-05-03', '10:00:00', N'Chuyển khoản', 3),
(N'2024-05-04', '11:00:00', N'Chuyển khoản', 4),
(N'2024-05-05', '12:00:00', N'Tiền mặt', 5),
(N'2024-05-06', '13:00:00', N'Tiền mặt', 6),
(N'2024-05-07', '14:00:00', N'Chuyển khoản', 7),
(N'2024-05-08', '15:00:00', N'Chuyển khoản', 8),
(N'2024-05-09', '16:00:00', N'Tiền mặt', 9),
(N'2024-05-10', '17:00:00', N'Tiền mặt', 10),
(N'2024-05-11', '18:00:00', N'Chuyển khoản', 11),
(N'2024-05-12', '19:00:00', N'Chuyển khoản', 12),
(N'2024-05-12', '20:00:00', N'Tiền mặt', 13),
(N'2024-05-12', '21:00:00', N'Tiền mặt', 14),
(N'2024-05-12', '22:00:00', N'Chuyển khoản', 15),
(N'2024-05-12', '23:00:00', N'Chuyển khoản', 16),
(N'2024-05-15', '08:00:00', N'Tiền mặt', 17),
(N'2024-05-15', '09:00:00', N'Tiền mặt', 18),
(N'2024-05-15', '10:00:00', N'Chuyển khoản', 19),
(N'2024-05-15', '11:00:00', N'Chuyển khoản', 20);


INSERT INTO [table] ([id], [number_seat])
VALUES
(1, 4),
(2, 6),
(3, 5),
(4, 4),
(5, 6),
(6, 2),
(7, 4),
(8, 6),
(9, 4),
(10, 3),
(11, 5),
(12, 3),
(13, 2),
(14, 5),
(15, 6);


INSERT INTO [order_table]([order_id], [table_id])
VALUES
(1,1),
(3,2),
(5,3),
(7,4),
(9,5),
(11,6),
(13,7),
(15,8),
(17,9),
(19,10);

INSERT INTO [delivery_service] ([name])
VALUES
(N'Giao hàng nhanh'),
(N'Shoppe'),
(N'Grab'),
(N'Now'),
(N'Giao hàng tiết kiệm'),
(N'Be');

INSERT INTO [delivery_service_order] ([tracking_code], [order_id], [delivery_service_id])
VALUES
(N'GH001', 2, 1),
(N'SH001', 4, 2),
(N'GR001', 6, 3),
(N'NO001', 8, 4),
(N'GHTK001', 10, 5),
(N'BE001', 12, 6),
(N'GH002', 14, 1),
(N'SH002', 16, 2),
(N'GR002', 18, 3),
(N'NO002', 20, 4);


