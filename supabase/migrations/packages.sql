create table public.packages (
  id uuid not null default gen_random_uuid (),
  name character varying(255) not null,
  description text not null,
  destination character varying(255) not null,
  country character varying(255) not null,
  category character varying(100) not null,
  duration_days integer not null,
  price numeric(10, 2) not null,
  currency character varying(3) null default 'USD'::character varying,
  max_participants integer not null,
  available_slots integer not null,
  difficulty_level character varying(50) null,
  minimum_age integer null default 0,
  included_services text[] null,
  excluded_services text[] null,
  itinerary jsonb null,
  contact_email character varying(255) not null,
  contact_phone character varying(50) not null,
  rating numeric(3, 2) null default 0.00,
  reviews_count integer null default 0,
  cover_image text not null,
  images text[] null default '{}'::text[],
  is_active boolean null default true,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint packages_pkey primary key (id)
) TABLESPACE pg_default;

create index IF not exists idx_packages_destination on public.packages using btree (destination) TABLESPACE pg_default;

create index IF not exists idx_packages_category on public.packages using btree (category) TABLESPACE pg_default;

create index IF not exists idx_packages_country on public.packages using btree (country) TABLESPACE pg_default;

create index IF not exists idx_packages_price on public.packages using btree (price) TABLESPACE pg_default;

create index IF not exists idx_packages_rating on public.packages using btree (rating) TABLESPACE pg_default;

create index IF not exists idx_packages_is_active on public.packages using btree (is_active) TABLESPACE pg_default;

create trigger update_packages_updated_at BEFORE
update on packages for EACH row
execute FUNCTION update_updated_at_column ();