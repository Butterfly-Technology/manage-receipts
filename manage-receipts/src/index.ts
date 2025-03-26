import express from 'express';
import sequelize from './config/db';
import router from './routes';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS before JSON parsing
app.use(cors({
  origin: '*', 
  credentials: true, 
  methods: ['GET', 'POST', 'PUT', 'DELETE'], 
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// ✅ Make sure JSON middleware is applied BEFORE routes
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// API Routes
app.use('/api', router);

// Start server
sequelize.sync()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`✅ Server is running on port ${PORT}`);
    });
  })
  .catch((error) => {
    console.error("❌ Error connecting to database:", error);
  });
