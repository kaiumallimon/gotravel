-- Add place_id foreign key to packages table
ALTER TABLE packages ADD COLUMN place_id UUID REFERENCES places(id);

-- Create index for better performance
CREATE INDEX idx_packages_place_id ON packages(place_id);

-- Update existing packages to have a place_id (optional, for existing data)
-- You can manually assign places to existing packages through admin panel