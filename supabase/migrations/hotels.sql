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