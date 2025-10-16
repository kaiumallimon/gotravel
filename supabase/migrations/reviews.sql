create table public.reviews (
  id uuid not null default gen_random_uuid (),
  user_id uuid not null,
  item_type character varying(20) not null, -- 'package', 'hotel', 'place'
  item_id uuid not null,
  booking_id uuid null, -- reference to booking if review is from actual booking
  
  -- Review Details
  rating integer not null, -- 1-5 stars
  title character varying(255) null,
  review_text text null,
  images text[] null default '{}', -- review photos
  
  -- Review Metadata
  is_verified boolean null default false, -- verified purchase/booking
  is_anonymous boolean null default false,
  helpful_count integer null default 0, -- number of users who found it helpful
  reported_count integer null default 0, -- number of times reported
  
  -- Status
  is_approved boolean null default true,
  is_featured boolean null default false,
  moderated_at timestamp with time zone null,
  moderated_by uuid null,
  moderation_notes text null,
  
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  
  constraint reviews_pkey primary key (id),
  constraint reviews_user_id_fkey foreign KEY (user_id) references auth.users (id) on delete CASCADE,
  constraint reviews_booking_id_fkey foreign KEY (booking_id) references bookings (id) on delete set null,
  constraint reviews_moderated_by_fkey foreign KEY (moderated_by) references auth.users (id) on delete set null,
  constraint reviews_unique_user_item unique (user_id, item_type, item_id, booking_id),
  constraint reviews_item_type_check check (
    (item_type)::text = any (
      array[
        'package'::character varying,
        'hotel'::character varying,
        'place'::character varying
      ]::text[]
    )
  ),
  constraint reviews_rating_check check (rating >= 1 and rating <= 5)
) TABLESPACE pg_default;

-- Indexes for better performance
create index IF not exists idx_reviews_user_id on public.reviews using btree (user_id) TABLESPACE pg_default;
create index IF not exists idx_reviews_item_type on public.reviews using btree (item_type) TABLESPACE pg_default;
create index IF not exists idx_reviews_item_id on public.reviews using btree (item_id) TABLESPACE pg_default;
create index IF not exists idx_reviews_rating on public.reviews using btree (rating) TABLESPACE pg_default;
create index IF not exists idx_reviews_is_approved on public.reviews using btree (is_approved) TABLESPACE pg_default;
create index IF not exists idx_reviews_is_featured on public.reviews using btree (is_featured) TABLESPACE pg_default;
create index IF not exists idx_reviews_created_at on public.reviews using btree (created_at) TABLESPACE pg_default;

-- Full text search index for review content
create index IF not exists idx_reviews_search on public.reviews using gin (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(review_text, ''))) TABLESPACE pg_default;

-- Trigger for updated_at
create trigger update_reviews_updated_at BEFORE
update on reviews for EACH row
execute FUNCTION update_updated_at_column ();