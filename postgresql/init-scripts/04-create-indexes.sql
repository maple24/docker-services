-- Connect to application database
\c myapp;

SET search_path TO app, public;

-- Users table indexes
CREATE INDEX idx_users_email ON app.users(email);
CREATE INDEX idx_users_username ON app.users(username);
CREATE INDEX idx_users_is_active ON app.users(is_active);
CREATE INDEX idx_users_created_at ON app.users(created_at DESC);

-- Sessions table indexes
CREATE INDEX idx_sessions_user_id ON app.sessions(user_id);
CREATE INDEX idx_sessions_token ON app.sessions(token);
CREATE INDEX idx_sessions_expires_at ON app.sessions(expires_at);

-- Posts table indexes
CREATE INDEX idx_posts_author_id ON app.posts(author_id);
CREATE INDEX idx_posts_category_id ON app.posts(category_id);
CREATE INDEX idx_posts_status ON app.posts(status);
CREATE INDEX idx_posts_published_at ON app.posts(published_at DESC);
CREATE INDEX idx_posts_slug ON app.posts(slug);
CREATE INDEX idx_posts_created_at ON app.posts(created_at DESC);

-- Full-text search index for posts
CREATE INDEX idx_posts_title_trgm ON app.posts USING gin(title gin_trgm_ops);
CREATE INDEX idx_posts_content_trgm ON app.posts USING gin(content gin_trgm_ops);

-- Comments table indexes
CREATE INDEX idx_comments_post_id ON app.comments(post_id);
CREATE INDEX idx_comments_user_id ON app.comments(user_id);
CREATE INDEX idx_comments_parent_id ON app.comments(parent_id);
CREATE INDEX idx_comments_is_approved ON app.comments(is_approved);
CREATE INDEX idx_comments_created_at ON app.comments(created_at DESC);

-- Categories table indexes
CREATE INDEX idx_categories_parent_id ON app.categories(parent_id);
CREATE INDEX idx_categories_slug ON app.categories(slug);
CREATE INDEX idx_categories_is_active ON app.categories(is_active);

-- Tags table indexes
CREATE INDEX idx_tags_slug ON app.tags(slug);

-- Post tags indexes
CREATE INDEX idx_post_tags_tag_id ON app.post_tags(tag_id);

-- Audit log indexes
CREATE INDEX idx_activity_log_user_id ON audit.activity_log(user_id);
CREATE INDEX idx_activity_log_action ON audit.activity_log(action);
CREATE INDEX idx_activity_log_table_name ON audit.activity_log(table_name);
CREATE INDEX idx_activity_log_created_at ON audit.activity_log(created_at DESC);

-- Uploads table indexes
CREATE INDEX idx_uploads_user_id ON app.uploads(user_id);
CREATE INDEX idx_uploads_created_at ON app.uploads(created_at DESC);

-- Notifications table indexes
CREATE INDEX idx_notifications_user_id ON app.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON app.notifications(is_read);
CREATE INDEX idx_notifications_created_at ON app.notifications(created_at DESC);
