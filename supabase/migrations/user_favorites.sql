create table public.user_favorites (
  id uuid not null default gen_random_uuid (),
  user_id uuid not null,
  item_type character varying(20) not null, -- 'package', 'hotel', 'place'
  item_id uuid not null,
  created_at timestamp with time zone null default now(),
  
  constraint user_favorites_pkey primary key (id),
  constraint user_favorites_user_id_fkey foreign KEY (user_id) references auth.users (id) on delete CASCADE,
  constraint user_favorites_unique_item unique (user_id, item_type, item_id),
  constraint user_favorites_item_type_check check (
    (item_type)::text = any (
      array[
        'package'::character varying,
        'hotel'::character varying,
        'place'::character varying
      ]::text[]
    )
  )
) TABLESPACE pg_default;

-- Indexes for better performance
create index IF not exists idx_user_favorites_user_id on public.user_favorites using btree (user_id) TABLESPACE pg_default;
create index IF not exists idx_user_favorites_item_type on public.user_favorites using btree (item_type) TABLESPACE pg_default;
create index IF not exists idx_user_favorites_item_id on public.user_favorites using btree (item_id) TABLESPACE pg_default;
create index IF not exists idx_user_favorites_created_at on public.user_favorites using btree (created_at) TABLESPACE pg_default;