-- Hotels and Rooms Table Creation
create table public.hotels (
  id uuid not null default gen_random_uuid (),
  name text not null,
  description text null,
  address text null,
  city text null,
  country text null,
  latitude double precision null,
  longitude double precision null,
  contact_email text null,
  phone text null,
  rating numeric(2, 1) null default 0.0,
  reviews_count integer null default 0,
  cover_image text null,
  images text[] null default '{}'::text[],
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint hotels_pkey primary key (id)
) TABLESPACE pg_default;

create index IF not exists idx_hotels_city on public.hotels using btree (city) TABLESPACE pg_default;
create index IF not exists idx_hotels_country on public.hotels using btree (country) TABLESPACE pg_default;

create table public.rooms (
  id uuid not null default gen_random_uuid (),
  hotel_id uuid null,
  room_type text not null,
  price_per_night numeric(10, 2) not null,
  currency text null default 'BDT'::text,
  capacity integer not null,
  bed_type text null,
  amenities text[] null default '{}'::text[],
  available_count integer null default 0,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint rooms_pkey primary key (id),
  constraint rooms_hotel_id_fkey foreign KEY (hotel_id) references hotels (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_rooms_hotel_id on public.rooms using btree (hotel_id) TABLESPACE pg_default;

-- Sample Hotel Data
INSERT INTO public.hotels (id, name, description, address, city, country, latitude, longitude, contact_email, phone, rating, reviews_count, cover_image, images) VALUES

-- Paris Hotels
('11111111-1111-1111-1111-111111111111', 'Hotel Ritz Paris', 'Legendary luxury hotel in the heart of Paris, offering unparalleled elegance and world-class service since 1898.', '15 Place Vendôme', 'Paris', 'France', 48.8682, 2.3292, 'reservations@ritzparis.com', '+33 1 43 16 30 30', 4.8, 2847, 'https://example.com/ritz-paris-cover.jpg', ARRAY['https://example.com/ritz-1.jpg', 'https://example.com/ritz-2.jpg', 'https://example.com/ritz-3.jpg']),

('22222222-2222-2222-2222-222222222222', 'Le Meurice', 'Palace hotel overlooking the Tuileries Garden, blending French tradition with contemporary luxury.', '228 Rue de Rivoli', 'Paris', 'France', 48.8647, 2.3261, 'info@lemeurice.com', '+33 1 44 58 10 10', 4.7, 1923, 'https://example.com/le-meurice-cover.jpg', ARRAY['https://example.com/meurice-1.jpg', 'https://example.com/meurice-2.jpg']),

('33333333-3333-3333-3333-333333333333', 'Hotel des Grands Boulevards', 'Charming boutique hotel in the vibrant Grands Boulevards district with modern Parisian style.', '17 Boulevard Poissonnière', 'Paris', 'France', 48.8714, 2.3420, 'hello@hoteldesgrandsboulevards.com', '+33 1 85 73 33 33', 4.5, 856, 'https://example.com/grands-boulevards-cover.jpg', ARRAY['https://example.com/boulevards-1.jpg', 'https://example.com/boulevards-2.jpg']),

-- Tokyo Hotels
('44444444-4444-4444-4444-444444444444', 'The Peninsula Tokyo', 'Ultra-modern luxury hotel in Marunouchi with stunning Imperial Palace views and exceptional service.', '1-8-1 Yurakucho, Chiyoda City', 'Tokyo', 'Japan', 35.6751, 139.7637, 'ptk@peninsula.com', '+81 3 6270 2888', 4.9, 3241, 'https://example.com/peninsula-tokyo-cover.jpg', ARRAY['https://example.com/peninsula-1.jpg', 'https://example.com/peninsula-2.jpg', 'https://example.com/peninsula-3.jpg']),

('55555555-5555-5555-5555-555555555555', 'Hoshinoya Tokyo', 'Traditional ryokan experience in the heart of modern Tokyo, featuring tatami rooms and onsen baths.', '1-9-1 Otemachi, Chiyoda City', 'Tokyo', 'Japan', 35.6866, 139.7669, 'reservation@hoshinoya.com', '+81 3 5220 2255', 4.6, 1687, 'https://example.com/hoshinoya-cover.jpg', ARRAY['https://example.com/hoshinoya-1.jpg', 'https://example.com/hoshinoya-2.jpg']),

-- Switzerland Hotels
('66666666-6666-6666-6666-666666666666', 'The Chedi Andermatt', 'Contemporary alpine luxury resort combining Swiss hospitality with Asian-inspired design.', 'Gotthardstrasse 4', 'Andermatt', 'Switzerland', 46.6358, 8.5937, 'andermatt@ghmhotels.com', '+41 41 888 74 88', 4.8, 2156, 'https://example.com/chedi-andermatt-cover.jpg', ARRAY['https://example.com/chedi-1.jpg', 'https://example.com/chedi-2.jpg']),

('77777777-7777-7777-7777-777777777777', 'Grand Hotel Kronenhof', 'Historic grand hotel in the heart of the Engadin valley, offering alpine elegance since 1848.', 'Via Maistra 142', 'Pontresina', 'Switzerland', 46.4969, 9.9053, 'info@kronenhof.com', '+41 81 830 30 30', 4.7, 1834, 'https://example.com/kronenhof-cover.jpg', ARRAY['https://example.com/kronenhof-1.jpg', 'https://example.com/kronenhof-2.jpg']),

-- Dhaka Hotels
('88888888-8888-8888-8888-888888888888', 'InterContinental Dhaka', 'Premier international hotel in the diplomatic zone with panoramic city views and world-class amenities.', 'Minto Road, Dhaka 1000', 'Dhaka', 'Bangladesh', 23.7367, 90.3986, 'dhaka@ihg.com', '+880 2 9861000', 4.4, 2976, 'https://example.com/intercontinental-dhaka-cover.jpg', ARRAY['https://example.com/ic-dhaka-1.jpg', 'https://example.com/ic-dhaka-2.jpg']),

('99999999-9999-9999-9999-999999999999', 'The Westin Dhaka', 'Contemporary luxury hotel in Gulshan featuring sophisticated accommodations and extensive facilities.', 'Plot 01, Road 45, Gulshan Avenue', 'Dhaka', 'Bangladesh', 23.7925, 90.4078, 'westin.dhaka@westin.com', '+880 2 8836000', 4.3, 1847, 'https://example.com/westin-dhaka-cover.jpg', ARRAY['https://example.com/westin-1.jpg', 'https://example.com/westin-2.jpg']),

('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Pan Pacific Sonargaon Dhaka', 'Iconic heritage hotel offering traditional Bangladeshi hospitality with modern luxury amenities.', '107 Kazi Nazrul Islam Avenue', 'Dhaka', 'Bangladesh', 23.7512, 90.3912, 'ppsd.reservations@panpacific.com', '+880 2 9666501', 4.2, 3247, 'https://example.com/sonargaon-cover.jpg', ARRAY['https://example.com/sonargaon-1.jpg', 'https://example.com/sonargaon-2.jpg']);

-- Sample Room Data
INSERT INTO public.rooms (hotel_id, room_type, price_per_night, currency, capacity, bed_type, amenities, available_count) VALUES

-- Hotel Ritz Paris Rooms
('11111111-1111-1111-1111-111111111111', 'Deluxe Room', 850.00, 'EUR', 2, 'King', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Room Service', 'Concierge', 'Marble Bathroom'], 15),
('11111111-1111-1111-1111-111111111111', 'Junior Suite', 1200.00, 'EUR', 2, 'King', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Room Service', 'Concierge', 'Marble Bathroom', 'Separate Living Area', 'Butler Service'], 8),
('11111111-1111-1111-1111-111111111111', 'Presidential Suite', 5000.00, 'EUR', 4, 'King + Sofa Bed', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Room Service', 'Concierge', 'Marble Bathroom', 'Private Terrace', 'Butler Service', 'Dining Room'], 2),

-- Le Meurice Rooms
('22222222-2222-2222-2222-222222222222', 'Classic Room', 720.00, 'EUR', 2, 'Queen', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Room Service', 'Garden View'], 20),
('22222222-2222-2222-2222-222222222222', 'Deluxe Suite', 1500.00, 'EUR', 3, 'King + Single', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Room Service', 'Tuileries Garden View', 'Separate Living Area'], 6),

-- Hotel des Grands Boulevards Rooms
('33333333-3333-3333-3333-333333333333', 'Standard Room', 280.00, 'EUR', 2, 'Double', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Modern Design'], 25),
('33333333-3333-3333-3333-333333333333', 'Superior Room', 350.00, 'EUR', 2, 'King', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'City View', 'Modern Design'], 12),

-- The Peninsula Tokyo Rooms
('44444444-4444-4444-4444-444444444444', 'Deluxe Room', 65000.00, 'JPY', 2, 'King', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'City View', 'High-tech Amenities'], 18),
('44444444-4444-4444-4444-444444444444', 'Peninsula Suite', 120000.00, 'JPY', 4, 'King + Sofa Bed', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Imperial Palace View', 'Butler Service', 'Separate Living Area'], 5),

-- Hoshinoya Tokyo Rooms
('55555555-5555-5555-5555-555555555555', 'Tatami Room', 85000.00, 'JPY', 2, 'Futon', ARRAY['Wi-Fi', 'Traditional Bath', 'Tatami Flooring', 'Onsen Access', 'Tea Set'], 16),
('55555555-5555-5555-5555-555555555555', 'Premium Tatami Suite', 150000.00, 'JPY', 4, 'Futon + Extra Bedding', ARRAY['Wi-Fi', 'Private Onsen', 'Tatami Flooring', 'Tea Ceremony Set', 'Garden View'], 4),

-- The Chedi Andermatt Rooms
('66666666-6666-6666-6666-666666666666', 'Deluxe Room', 800.00, 'CHF', 2, 'King', ARRAY['Wi-Fi', 'Mini Bar', 'Mountain View', 'Heated Floors', 'Spa Access'], 22),
('66666666-6666-6666-6666-666666666666', 'Alpine Suite', 1500.00, 'CHF', 4, 'King + Sofa Bed', ARRAY['Wi-Fi', 'Mini Bar', 'Mountain View', 'Fireplace', 'Private Balcony', 'Spa Access'], 8),

-- Grand Hotel Kronenhof Rooms
('77777777-7777-7777-7777-777777777777', 'Classic Room', 650.00, 'CHF', 2, 'Queen', ARRAY['Wi-Fi', 'Mini Bar', 'Valley View', 'Traditional Decor'], 30),
('77777777-7777-7777-7777-777777777777', 'Grand Suite', 1800.00, 'CHF', 4, 'King + Twin', ARRAY['Wi-Fi', 'Mini Bar', 'Panoramic View', 'Antique Furnishings', 'Separate Living Area'], 6),

-- InterContinental Dhaka Rooms
('88888888-8888-8888-8888-888888888888', 'Deluxe Room', 12000.00, 'BDT', 2, 'King', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'City View', 'Club Access'], 35),
('88888888-8888-8888-8888-888888888888', 'Executive Suite', 25000.00, 'BDT', 3, 'King + Single', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Panoramic City View', 'Executive Lounge', 'Butler Service'], 10),

-- The Westin Dhaka Rooms
('99999999-9999-9999-9999-999999999999', 'Deluxe Room', 11000.00, 'BDT', 2, 'King', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Heavenly Bed', 'Lake View'], 28),
('99999999-9999-9999-9999-999999999999', 'Presidential Suite', 45000.00, 'BDT', 6, 'King + Twin + Sofa Bed', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Private Dining', 'Butler Service', 'Panoramic View'], 3),

-- Pan Pacific Sonargaon Dhaka Rooms
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Superior Room', 9500.00, 'BDT', 2, 'Queen', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Garden View'], 40),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Heritage Suite', 22000.00, 'BDT', 4, 'King + Twin', ARRAY['Wi-Fi', 'Mini Bar', 'Air Conditioning', 'Traditional Decor', 'Separate Living Area', 'Heritage Collection'], 8);