-- Chat conversations table
create table public.conversations (
  id uuid not null default gen_random_uuid (),
  user_id uuid not null,
  title character varying(255) null default 'New Conversation',
  is_active boolean null default true,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint conversations_pkey primary key (id),
  constraint conversations_user_id_fkey foreign key (user_id) references public.users (id) on delete cascade
) TABLESPACE pg_default;

-- Chat messages table
create table public.messages (
  id uuid not null default gen_random_uuid (),
  conversation_id uuid not null,
  role character varying(20) not null, -- 'user', 'assistant', 'system'
  content text not null,
  metadata jsonb null default '{}'::jsonb, -- for storing tool calls, function responses, etc.
  tokens_used integer null default 0,
  created_at timestamp with time zone null default now(),
  constraint messages_pkey primary key (id),
  constraint messages_conversation_id_fkey foreign key (conversation_id) references public.conversations (id) on delete cascade,
  constraint messages_role_check check (role = any (array['user'::text, 'assistant'::text, 'system'::text]))
) TABLESPACE pg_default;

-- Indexes for better performance
create index IF not exists idx_conversations_user_id on public.conversations using btree (user_id) TABLESPACE pg_default;
create index IF not exists idx_conversations_is_active on public.conversations using btree (is_active) TABLESPACE pg_default;
create index IF not exists idx_conversations_created_at on public.conversations using btree (created_at) TABLESPACE pg_default;

create index IF not exists idx_messages_conversation_id on public.messages using btree (conversation_id) TABLESPACE pg_default;
create index IF not exists idx_messages_role on public.messages using btree (role) TABLESPACE pg_default;
create index IF not exists idx_messages_created_at on public.messages using btree (created_at) TABLESPACE pg_default;

-- Create updated_at trigger function if it doesn't exist
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Triggers for updated_at
create trigger update_conversations_updated_at 
  before update on conversations 
  for each row execute function update_updated_at_column();

-- RLS (Row Level Security) policies
alter table public.conversations enable row level security;
alter table public.messages enable row level security;

-- Users can only access their own conversations
create policy "Users can view their own conversations" on public.conversations
  for select using (auth.uid() = user_id);

create policy "Users can create their own conversations" on public.conversations
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own conversations" on public.conversations
  for update using (auth.uid() = user_id);

create policy "Users can delete their own conversations" on public.conversations
  for delete using (auth.uid() = user_id);

-- Users can only access messages from their conversations
create policy "Users can view messages from their conversations" on public.messages
  for select using (
    exists (
      select 1 from public.conversations 
      where conversations.id = messages.conversation_id 
      and conversations.user_id = auth.uid()
    )
  );

create policy "Users can create messages in their conversations" on public.messages
  for insert with check (
    exists (
      select 1 from public.conversations 
      where conversations.id = messages.conversation_id 
      and conversations.user_id = auth.uid()
    )
  );

create policy "Users can update messages in their conversations" on public.messages
  for update using (
    exists (
      select 1 from public.conversations 
      where conversations.id = messages.conversation_id 
      and conversations.user_id = auth.uid()
    )
  );

create policy "Users can delete messages from their conversations" on public.messages
  for delete using (
    exists (
      select 1 from public.conversations 
      where conversations.id = messages.conversation_id 
      and conversations.user_id = auth.uid()
    )
  );