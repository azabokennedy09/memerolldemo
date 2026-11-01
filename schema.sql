-- Who has a confirmed Premium payment. Run once in the Supabase SQL editor.
create table if not exists premium_members (
  code        text primary key,                       -- random member code created in the visitor's browser
  status      text not null check (status in ('active', 'inactive')),
  payer_email text,
  subscr_id   text,
  last_txn_id text,
  updated_at  timestamptz not null default now()
);

-- No policies on purpose: only the two edge functions (service role) can read or write this table.
alter table premium_members enable row level security;
