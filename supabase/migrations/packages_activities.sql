create table public.package_activities (
  id uuid not null default gen_random_uuid (),
  package_id uuid not null,
  day_number integer not null,
  activity_name character varying(255) not null,
  description text null,
  location character varying(255) null,
  start_time time without time zone null,
  end_time time without time zone null,
  activity_type character varying(100) null,
  is_optional boolean null default false,
  additional_cost numeric(10, 2) null default 0.00,
  created_at timestamp with time zone null default now(),
  constraint package_activities_pkey primary key (id),
  constraint package_activities_package_id_fkey foreign KEY (package_id) references packages (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_package_activities_package_id on public.package_activities using btree (package_id) TABLESPACE pg_default;

create index IF not exists idx_package_activities_day on public.package_activities using btree (day_number) TABLESPACE pg_default;