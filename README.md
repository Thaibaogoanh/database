# Backend Installation and Setup Guide

This guide will walk you through the steps to install and run the backend using Node.js, Express.js, and MySQL.

## Prerequisites

Before you begin, make sure you have the following installed on your machine:

- Node.js: [Download and install Node.js](https://nodejs.org)
- MySQL: [Download and install MySQL](https://www.mysql.com/downloads/)

## Installation

1. Clone the repository:

    ```shell
    git clone <repository-url>
    ```

2. Navigate to the project directory:

    ```shell
    cd <project-directory>
    ```

3. Install the dependencies:

    ```shell
    npm install
    ```

4. Create a `.env` file in the project root directory and configure the following environment variables:

    ```plaintext
    DB_HOST=<your-mysql-host>
    DB_USER=<your-mysql-username>
    DB_PASSWORD=<your-mysql-password>
    DB_NAME=<your-mysql-database-name>
    ```

## Database Setup

1. Create a new MySQL database using the MySQL command line or a GUI tool.

2. Import the database schema by running the following command:

    ```shell
    mysql -u <your-mysql-username> -p <your-mysql-database-name> < database/schema.sql
    ```

## Running the Backend

To start the backend server, run the following command:
    npm start
