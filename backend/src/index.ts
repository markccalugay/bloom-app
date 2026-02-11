import express, { Request, Response } from 'express';
import * as dotenv from 'dotenv';
import { verifyGoogleToken } from './auth_service';
import { upsertProgress, getProgress } from './database_service';

dotenv.config();

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;

app.post('/backup', async (req: Request, res: Response) => {
    try {
        const { idToken, data, schema_version } = req.body;

        if (!idToken || !data) {
            return res.status(400).json({ error: 'Missing idToken or data' });
        }

        const googleId = await verifyGoogleToken(idToken);
        await upsertProgress(googleId, data, schema_version || 1);

        res.json({ success: true });
    } catch (error: any) {
        res.status(401).json({ error: error.message });
    }
});

app.post('/restore', async (req: Request, res: Response) => {
    try {
        const { idToken } = req.body;

        if (!idToken) {
            return res.status(400).json({ error: 'Missing idToken' });
        }

        const googleId = await verifyGoogleToken(idToken);
        const progress = await getProgress(googleId);

        if (!progress) {
            return res.status(404).json({ error: 'No progress found' });
        }

        res.json({ data: progress.data, schema_version: progress.schema_version });
    } catch (error: any) {
        res.status(401).json({ error: error.message });
    }
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
