create table public.package_dates (
  id uuid not null default gen_random_uuid (),
  package_id uuid not null,
  departure_date date not null,
  return_date date not null,
  available_slots integer not null,
  price_override numeric(10, 2) null,
  is_active boolean null default true,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint package_dates_pkey primary key (id),
  constraint package_dates_package_id_fkey foreign KEY (package_id) references packages (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_package_dates_package_id on public.package_dates using btree (package_id) TABLESPACE pg_default;

create index IF not exists idx_package_dates_departure on public.package_dates using btree (departure_date) TABLESPACE pg_default;

create trigger update_package_dates_updated_at BEFORE
update on package_dates for EACH row
execute FUNCTION update_updated_at_column ();