DROP DATABASE IF EXISTS `coffee management`;

CREATE DATABASE IF NOT EXISTS `coffee management` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `coffee management`;

CREATE TABLE IF NOT EXISTS `employee` (
  `ssn` INT NOT NULL AUTO_INCREMENT,
  `cccd` VARCHAR(50) NOT NULL,
  `address` VARCHAR(500) NOT NULL,
  `job_type` VARCHAR(100) NOT NULL,
  `date_of_work` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `gender` ENUM ('MALE','FEMALE','OTHER') NOT NULL,
  `date_of_birth` DATE NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `middle_name` VARCHAR(50) NOT NULL,
  `first_name` VARCHAR(50) NOT NULL,
  `super_ssn` INT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ssn`),
  UNIQUE KEY `cccd` (`cccd`),
  CONSTRAINT `fk_emp_superssn` FOREIGN KEY (`super_ssn`) REFERENCES `employee` (`ssn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `employee_phone_number` (
  `ssn` INT NOT NULL,
  `phone_number` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`ssn`,`phone_number`),
  CONSTRAINT `fk_emp_phone_number` FOREIGN KEY (`ssn`) REFERENCES `employee` (`ssn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `full_time_employee` (
  `ssn` INT NOT NULL,
  `insurance` VARCHAR(50) NOT NULL,
  `month_salary` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`ssn`),
  CONSTRAINT `fk_ft_emp` FOREIGN KEY (`ssn`) REFERENCES `employee` (`ssn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `part_time_employee` (
  `ssn` INT NOT NULL,
  `hourly_salary` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`ssn`),
  CONSTRAINT `fk_pt_emp` FOREIGN KEY (`ssn`) REFERENCES `employee` (`ssn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `part_time_employee_works` (
  `ssn` INT NOT NULL,
  `date` DATE NOT NULL,
  `shift` ENUM ('7:00 AM - 12:00 AM','12:00 AM - 17:00 PM','17:00 PM - 22:00 PM') NOT NULL,
  PRIMARY KEY (`ssn`,`date`,`shift`),
  CONSTRAINT `fk_pt_emp_works` FOREIGN KEY (`ssn`) REFERENCES `part_time_employee` (`ssn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `employee_dependent` (
  `ssn` INT NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `relationship` VARCHAR(50) NOT NULL,
  `phone_number` VARCHAR(50) NOT NULL,
  `address` VARCHAR(500) NOT NULL,
  `date_of_birth` DATE NOT NULL,
  `gender` ENUM ('MALE','FEMALE','OTHER') NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ssn`,`name`),
  CONSTRAINT `fk_emp_dependent` FOREIGN KEY (`ssn`) REFERENCES `employee` (`ssn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

