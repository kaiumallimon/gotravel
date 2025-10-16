create table public.bookings (
  id uuid not null default gen_random_uuid (),
  user_id uuid not null,
  booking_type character varying(20) not null, -- 'package' or 'hotel'
  item_id uuid not null, -- references either packages.id or hotels.id
  booking_reference character varying(50) not null unique,
  
  -- Guest Information
  primary_guest_name character varying(255) not null,
  primary_guest_email character varying(255) not null,
  primary_guest_phone character varying(50) not null,
  total_participants integer null default 1,
  guest_details jsonb null, -- array of guest info objects
  
  -- Booking Details
  check_in_date date null, -- for hotels
  check_out_date date null, -- for hotels
  departure_date date null, -- for packages
  return_date date null, -- for packages
  package_date_id uuid null, -- references package_dates.id if booking a package
  room_id uuid null, -- references rooms.id if booking a hotel
  room_count integer null default 1, -- number of rooms for hotel bookings
  
  -- Pricing
  base_price numeric(10, 2) not null,
  additional_costs numeric(10, 2) null default 0.00, -- optional activities, extras
  discount_amount numeric(10, 2) null default 0.00,
  tax_amount numeric(10, 2) null default 0.00,
  total_amount numeric(10, 2) not null,
  currency character varying(3) null default 'USD',
  
  -- Status & Payment
  booking_status character varying(20) null default 'pending', -- pending, confirmed, cancelled, completed
  payment_status character varying(20) null default 'pending', -- pending, paid, failed, refunded
  payment_method character varying(50) null,
  payment_reference character varying(255) null,
  
  -- Special Requests
  special_requests text null,
  dietary_requirements text null,
  accessibility_needs text null,
  
  -- Metadata
  booking_source character varying(50) null default 'web', -- web, mobile, admin
  booking_notes text null, -- admin notes
  cancelled_at timestamp with time zone null,
  cancellation_reason text null,
  cancelled_by uuid null,
  
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  
  constraint bookings_pkey primary key (id),
  constraint bookings_user_id_fkey foreign KEY (user_id) references auth.users (id) on delete CASCADE,
  constraint bookings_package_date_id_fkey foreign KEY (package_date_id) references package_dates (id) on delete set null,
  constraint bookings_room_id_fkey foreign KEY (room_id) references rooms (id) on delete set null,
  constraint bookings_cancelled_by_fkey foreign KEY (cancelled_by) references auth.users (id) on delete set null,
  constraint bookings_booking_type_check check (
    (booking_type)::text = any (array['package'::character varying, 'hotel'::character varying]::text[])
  ),
  constraint bookings_booking_status_check check (
    (booking_status)::text = any (array['pending'::character varying, 'confirmed'::character varying, 'cancelled'::character varying, 'completed'::character varying]::text[])
  ),
  constraint bookings_payment_status_check check (
    (payment_status)::text = any (array['pending'::character varying, 'paid'::character varying, 'failed'::character varying, 'refunded'::character varying]::text[])
  )
) TABLESPACE pg_default;

-- Indexes for better performance
create index IF not exists idx_bookings_user_id on public.bookings using btree (user_id) TABLESPACE pg_default;
create index IF not exists idx_bookings_booking_type on public.bookings using btree (booking_type) TABLESPACE pg_default;
create index IF not exists idx_bookings_item_id on public.bookings using btree (item_id) TABLESPACE pg_default;
create index IF not exists idx_bookings_booking_reference on public.bookings using btree (booking_reference) TABLESPACE pg_default;
create index IF not exists idx_bookings_booking_status on public.bookings using btree (booking_status) TABLESPACE pg_default;
create index IF not exists idx_bookings_payment_status on public.bookings using btree (payment_status) TABLESPACE pg_default;
create index IF not exists idx_bookings_check_in_date on public.bookings using btree (check_in_date) TABLESPACE pg_default;
create index IF not exists idx_bookings_departure_date on public.bookings using btree (departure_date) TABLESPACE pg_default;
create index IF not exists idx_bookings_created_at on public.bookings using btree (created_at) TABLESPACE pg_default;

-- Trigger for updated_at
create trigger update_bookings_updated_at BEFORE
update on bookings for EACH row
execute FUNCTION update_updated_at_column ();