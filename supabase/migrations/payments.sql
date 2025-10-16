create table public.payments (
  id uuid not null default gen_random_uuid (),
  booking_id uuid not null,
  user_id uuid not null,
  payment_reference character varying(255) not null unique,
  
  -- Payment Details
  amount numeric(10, 2) not null,
  currency character varying(3) null default 'USD',
  payment_method character varying(50) not null, -- card, bank_transfer, mobile_money, etc.
  payment_provider character varying(50) null, -- stripe, paypal, bkash, etc.
  provider_transaction_id character varying(255) null,
  
  -- Payment Status
  payment_status character varying(20) null default 'pending', -- pending, processing, completed, failed, cancelled, refunded
  failure_reason text null,
  
  -- Card/Payment Method Details (encrypted/tokenized)
  payment_method_details jsonb null, -- masked card details, etc.
  
  -- Refund Information
  refund_amount numeric(10, 2) null default 0.00,
  refund_reason text null,
  refunded_at timestamp with time zone null,
  refunded_by uuid null,
  
  -- Metadata
  payment_gateway_response jsonb null, -- store gateway response for debugging
  payment_notes text null,
  processed_at timestamp with time zone null,
  
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  
  constraint payments_pkey primary key (id),
  constraint payments_booking_id_fkey foreign KEY (booking_id) references bookings (id) on delete CASCADE,
  constraint payments_user_id_fkey foreign KEY (user_id) references auth.users (id) on delete CASCADE,
  constraint payments_refunded_by_fkey foreign KEY (refunded_by) references auth.users (id) on delete set null,
  constraint payments_payment_status_check check (
    (payment_status)::text = any (
      array[
        'pending'::character varying,
        'processing'::character varying,
        'completed'::character varying,
        'failed'::character varying,
        'cancelled'::character varying,
        'refunded'::character varying
      ]::text[]
    )
  )
) TABLESPACE pg_default;

-- Indexes for better performance
create index IF not exists idx_payments_booking_id on public.payments using btree (booking_id) TABLESPACE pg_default;
create index IF not exists idx_payments_user_id on public.payments using btree (user_id) TABLESPACE pg_default;
create index IF not exists idx_payments_payment_reference on public.payments using btree (payment_reference) TABLESPACE pg_default;
create index IF not exists idx_payments_payment_status on public.payments using btree (payment_status) TABLESPACE pg_default;
create index IF not exists idx_payments_payment_method on public.payments using btree (payment_method) TABLESPACE pg_default;
create index IF not exists idx_payments_created_at on public.payments using btree (created_at) TABLESPACE pg_default;
create index IF not exists idx_payments_processed_at on public.payments using btree (processed_at) TABLESPACE pg_default;

-- Trigger for updated_at
create trigger update_payments_updated_at BEFORE
update on payments for EACH row
execute FUNCTION update_updated_at_column ();