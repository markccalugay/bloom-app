import { createClient } from '@supabase/supabase-js';
import * as dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

if (!supabaseUrl || !supabaseServiceKey) {
    throw new Error('Missing Supabase configuration in environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseServiceKey);

export async function upsertProgress(googleId: string, data: any, schemaVersion: number) {
    const { error } = await supabase
        .from('user_progress')
        .upsert(
            {
                google_id: googleId,
                data,
                schema_version: schemaVersion,
                updated_at: new Date()
            },
            { onConflict: 'google_id' }
        );

    if (error) {
        console.error('Error upserting progress:', error);
        throw error;
    }
}

export async function getProgress(googleId: string) {
    const { data, error } = await supabase
        .from('user_progress')
        .select('data, schema_version')
        .eq('google_id', googleId)
        .single();

    if (error && error.code !== 'PGRST116') { // PGRST116 is "No rows found"
        console.error('Error fetching progress:', error);
        throw error;
    }

    return data;
}
