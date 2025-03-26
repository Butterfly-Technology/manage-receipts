import { Sequelize } from 'sequelize';
import * as dotenv from 'dotenv';

// Initialize dotenv
dotenv.config();

// Create a Sequelize instance for PostgreSQL
const sequelize = new Sequelize({
  dialect: 'postgres',
  host: process.env.DB_HOST,
  port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : undefined, // Ensure port is added
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  logging: false, // Set to true to debug SQL queries
});

const syncDatabase = async () => {
  try {
    console.log(process.env.DB_USER, process.env.DB_PASS);

    await sequelize.sync({ alter: true }); // Use { force: true } to drop and recreate tables
    console.log('✅ Database synced successfully with PostgreSQL!');
  } catch (error) {
    console.error('❌ Error syncing database:', error);
  }
};

syncDatabase();

export default sequelize;
