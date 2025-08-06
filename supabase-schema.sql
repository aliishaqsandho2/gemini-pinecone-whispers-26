-- Create documents table
CREATE TABLE IF NOT EXISTS documents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  file_path TEXT,
  file_type TEXT NOT NULL,
  upload_date TIMESTAMPTZ DEFAULT NOW(),
  embedding FLOAT[] -- For storing vector embeddings
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  content TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  sources JSONB, -- For storing search result sources
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create storage bucket for documents
INSERT INTO storage.buckets (id, name, public) 
VALUES ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

-- Create storage policy for documents bucket
CREATE POLICY "Allow all operations on documents bucket" ON storage.objects
FOR ALL USING (bucket_id = 'documents');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_documents_upload_date ON documents(upload_date DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at ASC);

-- Enable Row Level Security (optional - currently allowing all access)
-- ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Create todos table
CREATE TABLE IF NOT EXISTS todos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create events table
CREATE TABLE IF NOT EXISTS events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create indexes for todos and events
CREATE INDEX IF NOT EXISTS todos_completed_idx ON todos(completed);
CREATE INDEX IF NOT EXISTS todos_created_at_idx ON todos(created_at);
CREATE INDEX IF NOT EXISTS events_start_date_idx ON events(start_date);

-- Enable Row Level Security for new tables
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Create policies for todos (allow all operations for now)
CREATE POLICY "Allow all operations on todos" ON todos
    FOR ALL USING (true);

-- Create policies for events (allow all operations for now)  
CREATE POLICY "Allow all operations on events" ON events
    FOR ALL USING (true);

-- Note: You'll need to run this SQL in your Supabase dashboard under SQL Editor