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