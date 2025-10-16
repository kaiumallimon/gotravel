create table public.places (
  id uuid not null default gen_random_uuid (),
  name character varying(255) not null,
  description text null,
  country character varying(255) not null,
  state_province character varying(255) null,
  city character varying(255) null,
  latitude double precision null,
  longitude double precision null,
  category character varying(100) null, -- beach, mountain, historical, cultural, etc.
  popular_ranking integer null default 0,
  visit_count integer null default 0,
  rating numeric(3, 2) null default 0.00,
  reviews_count integer null default 0,
  cover_image text not null,
  images text[] null default '{}'::text[],
  best_time_to_visit text null, -- JSON string with seasonal info
  average_temperature text null, -- JSON string with temp data
  currency character varying(3) null default 'USD',
  local_language character varying(100) null,
  time_zone character varying(100) null,
  famous_for text[] null default '{}', -- array of what place is known for
  activities text[] null default '{}', -- available activities
  is_featured boolean null default false,
  is_active boolean null default true,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint places_pkey primary key (id)
) TABLESPACE pg_default;

-- Indexes for better performance
create index IF not exists idx_places_country on public.places using btree (country) TABLESPACE pg_default;
create index IF not exists idx_places_city on public.places using btree (city) TABLESPACE pg_default;
create index IF not exists idx_places_category on public.places using btree (category) TABLESPACE pg_default;
create index IF not exists idx_places_rating on public.places using btree (rating) TABLESPACE pg_default;
create index IF not exists idx_places_popular_ranking on public.places using btree (popular_ranking) TABLESPACE pg_default;
create index IF not exists idx_places_is_featured on public.places using btree (is_featured) TABLESPACE pg_default;
create index IF not exists idx_places_is_active on public.places using btree (is_active) TABLESPACE pg_default;

-- Full text search index
create index IF not exists idx_places_search on public.places using gin (to_tsvector('english', name || ' ' || coalesce(description, '') || ' ' || country || ' ' || coalesce(city, ''))) TABLESPACE pg_default;

-- Trigger for updated_at
create trigger update_places_updated_at BEFORE
update on places for EACH row
execute FUNCTION update_updated_at_column ();