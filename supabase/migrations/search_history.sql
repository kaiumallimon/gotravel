create table public.search_history (
  id uuid not null default gen_random_uuid (),
  user_id uuid null, -- null for anonymous searches
  search_query character varying(500) not null,
  search_type character varying(50) null, -- 'places', 'packages', 'hotels', 'general'
  search_filters jsonb null, -- store applied filters
  results_count integer null default 0,
  clicked_item_id uuid null, -- track which result was clicked
  clicked_item_type character varying(20) null, -- 'package', 'hotel', 'place'
  ip_address inet null, -- for anonymous tracking
  user_agent text null,
  created_at timestamp with time zone null default now(),
  
  constraint search_history_pkey primary key (id),
  constraint search_history_user_id_fkey foreign KEY (user_id) references auth.users (id) on delete CASCADE,
  constraint search_history_clicked_item_type_check check (
    (clicked_item_type)::text = any (
      array[
        'package'::character varying,
        'hotel'::character varying,
        'place'::character varying
      ]::text[]
    )
  )
) TABLESPACE pg_default;

-- Indexes for better performance
create index IF not exists idx_search_history_user_id on public.search_history using btree (user_id) TABLESPACE pg_default;
create index IF not exists idx_search_history_search_type on public.search_history using btree (search_type) TABLESPACE pg_default;
create index IF not exists idx_search_history_created_at on public.search_history using btree (created_at) TABLESPACE pg_default;
create index IF not exists idx_search_history_search_query on public.search_history using gin (to_tsvector('english', search_query)) TABLESPACE pg_default;