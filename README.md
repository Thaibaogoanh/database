# Node.js, Express.js, and Microsoft SQL Server Example

This is a simple example that demonstrates how to set up a Node.js application with Express.js and Microsoft SQL Server.

## Prerequisites

Before you can run this application, make sure you have the following installed:

- [Node.js](https://nodejs.org) - JavaScript runtime environment
- [Express.js](https://expressjs.com) - Web application framework for Node.js
- [Microsoft SQL Server](https://www.microsoft.com/en-us/sql-server) - Relational database management system

## Installation

1. Clone this repository:

    ```shell
    git clone https://github.com/your-username/your-repo.git
    ```

2. Navigate to the project directory:

    ```shell
    cd your-repo
    ```

3. Install the dependencies:

    ```shell
    npm install
    ```

4. Set up the database:

    - Create a new database in Microsoft SQL Server.
    . Create a `.env` file in the project root directory and configure the following environment variables:

    ```plaintext
    PORT = <your-local-port>
    DB_USER = <your-sql-username>
    DB_PASSWORD = <your-sql-password>
    DB_SERVER = <your-sql-server> example 'localhost' or '127.0.0.1'
    DB_DATABASE = <your-sql-database-name> example 'master'
    URL = <http://localhost:${PORT}/api/v1> replace the PORT with the PORT above
    ```

5. Start the application:

    ```shell
    npm start
    ```

## Usage

Once the application is running, you can access it by opening your web browser and navigating to `http://localhost:<your-local-port>`.

## API Swagger

You can access the API Swagger documentation by navigating to `http://localhost:<your-local-port>/api/v1/employees/api-docs`.

## Contributing

Contributions are welcome! If you find any issues or have suggestions, please feel free to open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).