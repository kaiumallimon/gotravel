-- Packages table for tour packages
CREATE TABLE packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    destination VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL, -- adventure, cultural, relaxation, etc.
    duration_days INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    max_participants INTEGER NOT NULL,
    available_slots INTEGER NOT NULL,
    difficulty_level VARCHAR(50), -- easy, moderate, hard
    minimum_age INTEGER DEFAULT 0,
    included_services TEXT[], -- array of included services
    excluded_services TEXT[], -- array of excluded services
    itinerary JSONB, -- detailed daily itinerary
    contact_email VARCHAR(255) NOT NULL,
    contact_phone VARCHAR(50) NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0.00,
    reviews_count INTEGER DEFAULT 0,
    cover_image TEXT NOT NULL,
    images TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Package dates table for specific departure dates
CREATE TABLE package_dates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    package_id UUID NOT NULL REFERENCES packages(id) ON DELETE CASCADE,
    departure_date DATE NOT NULL,
    return_date DATE NOT NULL,
    available_slots INTEGER NOT NULL,
    price_override DECIMAL(10,2), -- optional price override for specific dates
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Package activities table for individual activities within a package
CREATE TABLE package_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    package_id UUID NOT NULL REFERENCES packages(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL,
    activity_name VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    start_time TIME,
    end_time TIME,
    activity_type VARCHAR(100), -- sightseeing, adventure, cultural, etc.
    is_optional BOOLEAN DEFAULT false,
    additional_cost DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for better performance
CREATE INDEX idx_packages_destination ON packages(destination);
CREATE INDEX idx_packages_category ON packages(category);
CREATE INDEX idx_packages_country ON packages(country);
CREATE INDEX idx_packages_price ON packages(price);
CREATE INDEX idx_packages_rating ON packages(rating);
CREATE INDEX idx_packages_is_active ON packages(is_active);
CREATE INDEX idx_package_dates_package_id ON package_dates(package_id);
CREATE INDEX idx_package_dates_departure ON package_dates(departure_date);
CREATE INDEX idx_package_activities_package_id ON package_activities(package_id);
CREATE INDEX idx_package_activities_day ON package_activities(day_number);

-- RLS (Row Level Security) policies
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE package_dates ENABLE ROW LEVEL SECURITY;
ALTER TABLE package_activities ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users
CREATE POLICY "Allow read access to packages" ON packages
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow read access to package_dates" ON package_dates
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow read access to package_activities" ON package_activities
    FOR SELECT TO authenticated USING (true);

-- Allow full access to admin users (assuming there's a users table with role column)
CREATE POLICY "Allow admin full access to packages" ON packages
    FOR ALL TO authenticated 
    USING (EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() AND users.role = 'admin'
    ));

CREATE POLICY "Allow admin full access to package_dates" ON package_dates
    FOR ALL TO authenticated 
    USING (EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() AND users.role = 'admin'
    ));

CREATE POLICY "Allow admin full access to package_activities" ON package_activities
    FOR ALL TO authenticated 
    USING (EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() AND users.role = 'admin'
    ));

-- Functions for updating timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for auto-updating updated_at
CREATE TRIGGER update_packages_updated_at BEFORE UPDATE ON packages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_package_dates_updated_at BEFORE UPDATE ON package_dates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();