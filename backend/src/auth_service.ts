import { OAuth2Client } from 'google-auth-library';

const client = new OAuth2Client();

export async function verifyGoogleToken(idToken: String): Promise<string> {
    try {
        const ticket = await client.verifyIdToken({
            idToken: idToken.toString(),
            // audience: process.env.GOOGLE_CLIENT_ID, // Optional: add if we have multiple clients
        });
        const payload = ticket.getPayload();
        if (!payload || !payload.sub) {
            throw new Error('Invalid token payload');
        }
        return payload.sub; // The unique Google User ID
    } catch (error) {
        console.error('Error verifying Google token:', error);
        throw new Error('Authentication failed');
    }
}
