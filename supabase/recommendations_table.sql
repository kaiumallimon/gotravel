-- Create recommendations table
CREATE TABLE IF NOT EXISTS recommendations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('package', 'hotel')),
    item_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    UNIQUE(item_type, item_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_recommendations_item_type ON recommendations(item_type);
CREATE INDEX IF NOT EXISTS idx_recommendations_item_id ON recommendations(item_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_created_at ON recommendations(created_at);

-- Enable RLS
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;

-- Policy for admins to manage recommendations
CREATE POLICY "Admin can manage recommendations" ON recommendations
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = auth.uid()
            AND users.role = 'admin'
        )
    );

-- Policy for users to view recommendations
CREATE POLICY "Users can view recommendations" ON recommendations
    FOR SELECT USING (true);

-- Grant permissions
GRANT ALL ON recommendations TO authenticated;
GRANT ALL ON recommendations TO anon;

-- Add some sample data (optional)
-- You can remove this section if you don't want sample data
INSERT INTO recommendations (item_type, item_id, created_by) 
SELECT 'package', id, (SELECT id FROM auth.users WHERE email LIKE '%admin%' LIMIT 1)
FROM packages 
WHERE is_active = true 
LIMIT 3
ON CONFLICT (item_type, item_id) DO NOTHING;

INSERT INTO recommendations (item_type, item_id, created_by) 
SELECT 'hotel', id, (SELECT id FROM auth.users WHERE email LIKE '%admin%' LIMIT 1)
FROM hotels 
LIMIT 3
ON CONFLICT (item_type, item_id) DO NOTHING;