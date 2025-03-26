import express from 'express';
import ImageController from '../controllers/receiptController';

const router = express.Router();

// Process receipt after frontend uploads the image to Cloudinary
router.post('/process-receipt', ImageController.processImageOCR);

// Get receipts by user
router.get('/receipts/:userId', ImageController.getReceiptsByUser);

export default router;
