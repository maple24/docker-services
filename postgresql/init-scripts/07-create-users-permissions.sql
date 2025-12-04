-- Connect to application database
\c myapp;

SET search_path TO app, public;

-- Create application user with limited privileges
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE USER app_user WITH PASSWORD 'app_password';
    END IF;
END $$;

-- Grant schema usage
GRANT USAGE ON SCHEMA app TO app_user;
GRANT USAGE ON SCHEMA audit TO app_user;

-- Grant table permissions (CRUD operations)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO app_user;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA audit TO app_user;

-- Grant sequence permissions (for serial/auto-increment columns)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA app TO app_user;

-- Grant execute on functions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA app TO app_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA audit TO app_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT USAGE, SELECT ON SEQUENCES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT EXECUTE ON FUNCTIONS TO app_user;

-- Create read-only user
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'readonly_user') THEN
        CREATE USER readonly_user WITH PASSWORD 'readonly_password';
    END IF;
END $$;

-- Grant read-only permissions
GRANT USAGE ON SCHEMA app TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA app TO readonly_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT ON TABLES TO readonly_user;

-- Print user information
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Database users created:';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Application user:';
    RAISE NOTICE '  Username: app_user';
    RAISE NOTICE '  Password: app_password';
    RAISE NOTICE '  Privileges: CRUD on app schema';
    RAISE NOTICE '';
    RAISE NOTICE 'Read-only user:';
    RAISE NOTICE '  Username: readonly_user';
    RAISE NOTICE '  Password: readonly_password';
    RAISE NOTICE '  Privileges: SELECT only on app schema';
    RAISE NOTICE '========================================';
    RAISE NOTICE '⚠️  IMPORTANT: Change these passwords in production!';
    RAISE NOTICE '========================================';
END $$;
