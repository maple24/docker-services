-- Connect to application database
\c myapp;

SET search_path TO app, public;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION app.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON app.users
    FOR EACH ROW
    EXECUTE FUNCTION app.update_updated_at_column();

-- Trigger for posts table
CREATE TRIGGER update_posts_updated_at
    BEFORE UPDATE ON app.posts
    FOR EACH ROW
    EXECUTE FUNCTION app.update_updated_at_column();

-- Trigger for comments table
CREATE TRIGGER update_comments_updated_at
    BEFORE UPDATE ON app.comments
    FOR EACH ROW
    EXECUTE FUNCTION app.update_updated_at_column();

-- Trigger for categories table
CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON app.categories
    FOR EACH ROW
    EXECUTE FUNCTION app.update_updated_at_column();

-- Function to log user activity
CREATE OR REPLACE FUNCTION audit.log_user_activity()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.activity_log (
            user_id, action, table_name, record_id, new_values
        ) VALUES (
            NEW.id, 'INSERT', TG_TABLE_NAME, NEW.id::TEXT, to_jsonb(NEW)
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.activity_log (
            user_id, action, table_name, record_id, old_values, new_values
        ) VALUES (
            NEW.id, 'UPDATE', TG_TABLE_NAME, NEW.id::TEXT, to_jsonb(OLD), to_jsonb(NEW)
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.activity_log (
            user_id, action, table_name, record_id, old_values
        ) VALUES (
            OLD.id, 'DELETE', TG_TABLE_NAME, OLD.id::TEXT, to_jsonb(OLD)
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Audit trigger for users table
CREATE TRIGGER audit_users
    AFTER INSERT OR UPDATE OR DELETE ON app.users
    FOR EACH ROW
    EXECUTE FUNCTION audit.log_user_activity();

-- Function to increment post view count
CREATE OR REPLACE FUNCTION app.increment_post_views(post_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE app.posts
    SET view_count = view_count + 1
    WHERE id = post_uuid;
END;
$$ LANGUAGE plpgsql;

-- Function to get post with author details
CREATE OR REPLACE FUNCTION app.get_post_with_author(post_uuid UUID)
RETURNS TABLE (
    post_id UUID,
    title VARCHAR,
    content TEXT,
    author_username VARCHAR,
    author_email VARCHAR,
    published_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.content,
        u.username,
        u.email,
        p.published_at
    FROM app.posts p
    LEFT JOIN app.users u ON p.author_id = u.id
    WHERE p.id = post_uuid;
END;
$$ LANGUAGE plpgsql;

-- Function to get user statistics
CREATE OR REPLACE FUNCTION app.get_user_stats(user_uuid UUID)
RETURNS TABLE (
    total_posts BIGINT,
    total_comments BIGINT,
    total_views BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT p.id)::BIGINT as total_posts,
        COUNT(DISTINCT c.id)::BIGINT as total_comments,
        COALESCE(SUM(p.view_count), 0)::BIGINT as total_views
    FROM app.users u
    LEFT JOIN app.posts p ON p.author_id = u.id
    LEFT JOIN app.comments c ON c.user_id = u.id
    WHERE u.id = user_uuid
    GROUP BY u.id;
END;
$$ LANGUAGE plpgsql;
