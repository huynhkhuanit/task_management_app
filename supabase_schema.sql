-- ============================================
-- SUPABASE DATABASE SCHEMA
-- Task Management App
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. PROFILES TABLE (extends auth.users)
-- ============================================
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    phone_number TEXT,
    avatar_url TEXT,
    language TEXT DEFAULT 'vi' CHECK (language IN ('vi', 'en', 'zh', 'ja')),
    dark_mode BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Add index for phone_number for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_phone_number ON public.profiles(phone_number);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Function to automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, phone_number)
    VALUES (
        NEW.id, 
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'phone_number'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile when user signs up
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- 2. CATEGORIES TABLE
-- ============================================
CREATE TABLE public.categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    icon_name TEXT NOT NULL, -- Store icon name (e.g., 'work_outline', 'person_outline')
    color_hex TEXT NOT NULL, -- Store color as hex (e.g., '#4FD1C7')
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(user_id, name)
);

-- Enable Row Level Security
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Categories policies
CREATE POLICY "Users can view own categories"
    ON public.categories FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own categories"
    ON public.categories FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own categories"
    ON public.categories FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own categories"
    ON public.categories FOR DELETE
    USING (auth.uid() = user_id);

-- Trigger to update updated_at
CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON public.categories
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- 3. TASKS TABLE
-- ============================================
CREATE TABLE public.tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    project TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'overdue')),
    priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    due_date TIMESTAMP WITH TIME ZONE,
    reminder_enabled BOOLEAN DEFAULT TRUE,
    reminder_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Enable Row Level Security
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Tasks policies
CREATE POLICY "Users can view own tasks"
    ON public.tasks FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tasks"
    ON public.tasks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks"
    ON public.tasks FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tasks"
    ON public.tasks FOR DELETE
    USING (auth.uid() = user_id);

-- Indexes for better query performance
CREATE INDEX idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX idx_tasks_category_id ON public.tasks(category_id);
CREATE INDEX idx_tasks_status ON public.tasks(status);
CREATE INDEX idx_tasks_priority ON public.tasks(priority);
CREATE INDEX idx_tasks_due_date ON public.tasks(due_date);
CREATE INDEX idx_tasks_created_at ON public.tasks(created_at DESC);

-- Trigger to update updated_at
CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON public.tasks
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Function to automatically set completed_at when status changes to completed
CREATE OR REPLACE FUNCTION public.handle_task_completion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        NEW.completed_at = TIMEZONE('utc'::text, NOW());
    ELSIF NEW.status != 'completed' THEN
        NEW.completed_at = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to handle task completion
CREATE TRIGGER on_task_completed
    BEFORE UPDATE ON public.tasks
    FOR EACH ROW EXECUTE FUNCTION public.handle_task_completion();

-- ============================================
-- 4. SUBTASKS TABLE
-- ============================================
CREATE TABLE public.subtasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.subtasks ENABLE ROW LEVEL SECURITY;

-- Subtasks policies (users can only access subtasks of their own tasks)
CREATE POLICY "Users can view subtasks of own tasks"
    ON public.subtasks FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = subtasks.task_id
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert subtasks for own tasks"
    ON public.subtasks FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = subtasks.task_id
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update subtasks of own tasks"
    ON public.subtasks FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = subtasks.task_id
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete subtasks of own tasks"
    ON public.subtasks FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = subtasks.task_id
            AND tasks.user_id = auth.uid()
        )
    );

-- Indexes
CREATE INDEX idx_subtasks_task_id ON public.subtasks(task_id);
CREATE INDEX idx_subtasks_is_completed ON public.subtasks(is_completed);

-- Trigger to update updated_at
CREATE TRIGGER update_subtasks_updated_at
    BEFORE UPDATE ON public.subtasks
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- 5. TASK_TAGS TABLE (Many-to-Many relationship)
-- ============================================
CREATE TABLE public.task_tags (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE NOT NULL,
    tag_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(task_id, tag_name)
);

-- Enable Row Level Security
ALTER TABLE public.task_tags ENABLE ROW LEVEL SECURITY;

-- Task tags policies
CREATE POLICY "Users can view tags of own tasks"
    ON public.task_tags FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = task_tags.task_id
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert tags for own tasks"
    ON public.task_tags FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = task_tags.task_id
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete tags of own tasks"
    ON public.task_tags FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = task_tags.task_id
            AND tasks.user_id = auth.uid()
        )
    );

-- Indexes
CREATE INDEX idx_task_tags_task_id ON public.task_tags(task_id);
CREATE INDEX idx_task_tags_tag_name ON public.task_tags(tag_name);

-- ============================================
-- 6. TASK_ATTACHMENTS TABLE
-- ============================================
CREATE TABLE public.task_attachments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE NOT NULL,
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL CHECK (file_type IN ('pdf', 'image', 'word', 'excel', 'other')),
    file_url TEXT NOT NULL, -- Supabase Storage URL
    file_size BIGINT, -- Size in bytes
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.task_attachments ENABLE ROW LEVEL SECURITY;

-- Task attachments policies
CREATE POLICY "Users can view attachments of own tasks"
    ON public.task_attachments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = task_attachments.task_id
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert attachments for own tasks"
    ON public.task_attachments FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = task_attachments.task_id
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete attachments of own tasks"
    ON public.task_attachments FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = task_attachments.task_id
            AND tasks.user_id = auth.uid()
        )
    );

-- Indexes
CREATE INDEX idx_task_attachments_task_id ON public.task_attachments(task_id);

-- ============================================
-- 7. NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('overdue', 'upcoming', 'reminder', 'newTask')),
    title TEXT NOT NULL,
    description TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Notifications policies
CREATE POLICY "Users can view own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications"
    ON public.notifications FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own notifications"
    ON public.notifications FOR DELETE
    USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_task_id ON public.notifications(task_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX idx_notifications_type ON public.notifications(type);

-- ============================================
-- 8. VIEWS FOR STATISTICS
-- ============================================

-- View for task statistics
CREATE OR REPLACE VIEW public.task_statistics AS
SELECT 
    t.user_id,
    COUNT(*) FILTER (WHERE t.status = 'completed') as completed_count,
    COUNT(*) FILTER (WHERE t.status = 'pending') as pending_count,
    COUNT(*) FILTER (WHERE t.status = 'overdue') as overdue_count,
    COUNT(*) as total_count,
    COUNT(*) FILTER (WHERE t.due_date < NOW() AND t.status != 'completed') as overdue_tasks_count,
    ROUND(
        CASE 
            WHEN COUNT(*) > 0 THEN 
                (COUNT(*) FILTER (WHERE t.status = 'completed')::DECIMAL / COUNT(*)::DECIMAL) * 100
            ELSE 0
        END, 
        2
    ) as completion_rate
FROM public.tasks t
GROUP BY t.user_id;

-- Enable Row Level Security on view
ALTER VIEW public.task_statistics SET (security_invoker = true);

-- ============================================
-- 9. FUNCTIONS FOR AUTOMATIC NOTIFICATIONS
-- ============================================

-- Function to create notification for overdue tasks
CREATE OR REPLACE FUNCTION public.create_overdue_notifications()
RETURNS void AS $$
BEGIN
    INSERT INTO public.notifications (user_id, task_id, type, title, description)
    SELECT 
        t.user_id,
        t.id,
        'overdue',
        'Quá hạn: ' || t.title,
        'Công việc này đã quá hạn. Vui lòng hoàn thành ngay.'
    FROM public.tasks t
    WHERE t.due_date < NOW()
        AND t.status NOT IN ('completed')
        AND NOT EXISTS (
            SELECT 1 FROM public.notifications n
            WHERE n.task_id = t.id
            AND n.type = 'overdue'
            AND n.created_at > NOW() - INTERVAL '1 day'
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create notification for upcoming tasks
CREATE OR REPLACE FUNCTION public.create_upcoming_notifications()
RETURNS void AS $$
BEGIN
    INSERT INTO public.notifications (user_id, task_id, type, title, description)
    SELECT 
        t.user_id,
        t.id,
        'upcoming',
        'Sắp tới hạn: ' || t.title,
        'Công việc sẽ hết hạn vào ' || TO_CHAR(t.due_date, 'HH24:MI') || ' ngày ' || TO_CHAR(t.due_date, 'DD/MM/YYYY') || '.'
    FROM public.tasks t
    WHERE t.due_date BETWEEN NOW() AND NOW() + INTERVAL '1 hour'
        AND t.status NOT IN ('completed')
        AND t.reminder_enabled = TRUE
        AND NOT EXISTS (
            SELECT 1 FROM public.notifications n
            WHERE n.task_id = t.id
            AND n.type = 'upcoming'
            AND n.created_at > NOW() - INTERVAL '1 hour'
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 10. STORAGE BUCKET FOR ATTACHMENTS
-- ============================================
-- Note: This needs to be created via Supabase Dashboard or API
-- Bucket name: task-attachments
-- Public: false
-- File size limit: 10MB
-- Allowed MIME types: pdf, image/*, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document, 
--                     application/vnd.ms-excel, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

-- Storage policies (to be created via Supabase Dashboard or API)
-- Users can upload files to their own folder: {user_id}/{task_id}/
-- Users can view/download files from their own folder
-- Users can delete files from their own folder

-- ============================================
-- 11. SAMPLE DATA (Optional - for testing)
-- ============================================
-- Note: Only run this if you want sample data for testing
-- Make sure to replace 'YOUR_USER_ID' with actual user ID

/*
-- Sample category
INSERT INTO public.categories (user_id, name, icon_name, color_hex, display_order)
VALUES ('YOUR_USER_ID', 'Công việc', 'work_outline', '#4FD1C7', 0);

-- Sample task
INSERT INTO public.tasks (user_id, category_id, title, description, project, status, priority, due_date)
VALUES (
    'YOUR_USER_ID',
    (SELECT id FROM public.categories WHERE name = 'Công việc' LIMIT 1),
    'Thiết kế giao diện màn hình',
    'Hoàn thiện thiết kế UI/UX cho màn hình thông tin người dùng',
    'Project X',
    'pending',
    'high',
    NOW() + INTERVAL '2 days'
);
*/

-- ============================================
-- END OF SCHEMA
-- ============================================

