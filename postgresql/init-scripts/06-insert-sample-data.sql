-- Connect to application database
\c myapp;

SET search_path TO app, public;

-- Insert default roles
INSERT INTO app.roles (name, description) VALUES
    ('admin', 'Administrator with full access'),
    ('editor', 'Can create and edit content'),
    ('author', 'Can create own content'),
    ('user', 'Regular user with basic access')
ON CONFLICT (name) DO NOTHING;

-- Insert default admin user (password: admin123 - CHANGE THIS!)
-- Password hash for 'admin123' using crypt function
INSERT INTO app.users (
    username, 
    email, 
    password_hash, 
    first_name, 
    last_name, 
    is_active, 
    is_verified
) VALUES (
    'admin',
    'admin@example.com',
    crypt('admin123', gen_salt('bf')),
    'Admin',
    'User',
    TRUE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

-- Assign admin role to admin user
INSERT INTO app.user_roles (user_id, role_id)
SELECT u.id, r.id
FROM app.users u, app.roles r
WHERE u.username = 'admin' AND r.name = 'admin'
ON CONFLICT DO NOTHING;

-- Insert sample categories
INSERT INTO app.categories (name, slug, description, display_order) VALUES
    ('Technology', 'technology', 'Posts about technology and software', 1),
    ('Science', 'science', 'Scientific articles and discoveries', 2),
    ('Business', 'business', 'Business and entrepreneurship content', 3),
    ('Lifestyle', 'lifestyle', 'Lifestyle and personal development', 4),
    ('Entertainment', 'entertainment', 'Entertainment and media content', 5)
ON CONFLICT (name) DO NOTHING;

-- Insert sample tags
INSERT INTO app.tags (name, slug) VALUES
    ('Tutorial', 'tutorial'),
    ('Guide', 'guide'),
    ('News', 'news'),
    ('Review', 'review'),
    ('Opinion', 'opinion'),
    ('Analysis', 'analysis'),
    ('Tips', 'tips'),
    ('How-to', 'how-to')
ON CONFLICT (name) DO NOTHING;

-- Insert default settings
INSERT INTO app.settings (key, value, data_type, description, is_public) VALUES
    ('site_name', 'My Application', 'string', 'Application name', TRUE),
    ('site_description', 'A sample application', 'string', 'Site description', TRUE),
    ('posts_per_page', '10', 'number', 'Number of posts per page', TRUE),
    ('enable_comments', 'true', 'boolean', 'Enable/disable comments', TRUE),
    ('comment_moderation', 'true', 'boolean', 'Require comment approval', FALSE),
    ('max_upload_size', '10485760', 'number', 'Maximum file upload size in bytes (10MB)', FALSE),
    ('allowed_file_types', '["image/jpeg", "image/png", "image/gif", "application/pdf"]', 'json', 'Allowed file MIME types', FALSE)
ON CONFLICT (key) DO NOTHING;

-- Insert a sample post
INSERT INTO app.posts (
    title,
    slug,
    content,
    excerpt,
    author_id,
    category_id,
    status,
    published_at
)
SELECT
    'Welcome to PostgreSQL',
    'welcome-to-postgresql',
    'This is your first post created during database initialization. PostgreSQL is a powerful, open-source relational database system with over 30 years of active development.',
    'Welcome post explaining PostgreSQL basics',
    u.id,
    c.id,
    'published',
    CURRENT_TIMESTAMP
FROM app.users u, app.categories c
WHERE u.username = 'admin' AND c.slug = 'technology'
ON CONFLICT (slug) DO NOTHING;

-- Tag the sample post
INSERT INTO app.post_tags (post_id, tag_id)
SELECT p.id, t.id
FROM app.posts p, app.tags t
WHERE p.slug = 'welcome-to-postgresql' AND t.slug IN ('guide', 'tutorial')
ON CONFLICT DO NOTHING;

-- Create views for common queries
CREATE OR REPLACE VIEW app.published_posts AS
SELECT 
    p.id,
    p.title,
    p.slug,
    p.excerpt,
    p.view_count,
    p.published_at,
    u.username as author_username,
    u.first_name as author_first_name,
    u.last_name as author_last_name,
    c.name as category_name,
    c.slug as category_slug,
    (SELECT COUNT(*) FROM app.comments WHERE post_id = p.id AND is_approved = TRUE) as comment_count
FROM app.posts p
LEFT JOIN app.users u ON p.author_id = u.id
LEFT JOIN app.categories c ON p.category_id = c.id
WHERE p.status = 'published' AND p.published_at <= CURRENT_TIMESTAMP
ORDER BY p.published_at DESC;

-- View for user statistics
CREATE OR REPLACE VIEW app.user_statistics AS
SELECT 
    u.id,
    u.username,
    u.email,
    COUNT(DISTINCT p.id) as total_posts,
    COUNT(DISTINCT c.id) as total_comments,
    COALESCE(SUM(p.view_count), 0) as total_views,
    u.created_at as member_since
FROM app.users u
LEFT JOIN app.posts p ON p.author_id = u.id
LEFT JOIN app.comments c ON c.user_id = u.id
GROUP BY u.id;

-- Print success message
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Database initialization completed!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Default admin user created:';
    RAISE NOTICE '  Username: admin';
    RAISE NOTICE '  Password: admin123';
    RAISE NOTICE '  Email: admin@example.com';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  IMPORTANT: Change the admin password immediately!';
    RAISE NOTICE '========================================';
END $$;
