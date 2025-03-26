import { Request, Response } from 'express';
import { Image } from '../models/Image';
import { Receipt } from '../models/Receipt';
import dayjs from "dayjs";
import axios from "axios";

const FASTAPI_OCR_URL = "http://localhost:8000/process-ocr"; // Change this if hosted elsewhere

export const processImageOCR = async (req: Request, res: Response) => {
  try {
    const { userId, imageUrl } = req.body;

    if (!userId || !imageUrl) {
      return res.status(400).json({ error: "Missing required fields" });
    }
    
    const ocrResponse = await axios.post(FASTAPI_OCR_URL, { imageUrl });
    
    const { vendor_name, total_amount, date, raw_text } = ocrResponse.data;
    

    if (ocrResponse.status !== 200) {
      return res.status(400).json({ error: "OCR processing failed" });
    }

    // 🔹 **2. Process OCR Data**
    const merchant = vendor_name || "Unknown";
    const amount = total_amount !== "N/A" ? parseFloat(total_amount) : 0;
    const receiptDate = dayjs(date, ["MM/DD/YYYY", "YYYY-MM-DD"]);

    console.log("Extracted OCR Data:", { merchant, amount, receiptDate, raw_text });

    // 🔹 **3. Save Image in Database**
    const image = await Image.create({ userId, imagePath: imageUrl });

    // 🔹 **4. Save Receipt Data**
    const receipt = await Receipt.create({
      userId,
      merchant,
      amount,
      receiptDate: receiptDate.toISOString(),
      imageId: image.id,
    });

    res.status(201).json({
      message: "Receipt processed successfully",
      receipt,
    });
  } catch (error) {
    console.error("OCR Processing Error:", error);
    res.status(500).json({ error: "Server error" });
  }
};


export const getReceiptsByUser = async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;

    const receipts = await Receipt.findAll({
      where: { userId },
      include: [{ model: Image }],
    });

    res.status(200).json(receipts);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
};

export default { processImageOCR, getReceiptsByUser };
