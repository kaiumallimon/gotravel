create table public.recommendations (
  id uuid not null default gen_random_uuid (),
  item_type character varying(20) not null,
  item_id uuid not null,
  created_at timestamp with time zone null default now(),
  created_by uuid null,
  constraint recommendations_pkey primary key (id),
  constraint recommendations_item_type_item_id_key unique (item_type, item_id),
  constraint recommendations_created_by_fkey foreign KEY (created_by) references auth.users (id) on delete CASCADE,
  constraint recommendations_item_type_check check (
    (
      (item_type)::text = any (
        (
          array[
            'package'::character varying,
            'hotel'::character varying
          ]
        )::text[]
      )
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_recommendations_item_type on public.recommendations using btree (item_type) TABLESPACE pg_default;

create index IF not exists idx_recommendations_item_id on public.recommendations using btree (item_id) TABLESPACE pg_default;

create index IF not exists idx_recommendations_created_at on public.recommendations using btree (created_at) TABLESPACE pg_default;