-- Enable PostGIS for location queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ENUMS
CREATE TYPE user_role AS ENUM ('customer', 'shopkeeper', 'admin');
CREATE TYPE order_status AS ENUM ('pending', 'accepted', 'rejected', 'ready', 'delivered');
CREATE TYPE return_status AS ENUM ('requested', 'approved', 'rejected', 'completed');
CREATE TYPE payment_method AS ENUM ('upi', 'cod');

-- 1. Users Table
CREATE TABLE users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone_number TEXT UNIQUE NOT NULL,
    role user_role NOT NULL DEFAULT 'customer',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Shops Table
CREATE TABLE shops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shopkeeper_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    location geography(POINT, 4326) NOT NULL, -- PostGIS point for lat/lng
    is_open BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create a spatial index for fast location queries
CREATE INDEX shops_location_idx ON shops USING GIST (location);

-- 3. Products Table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Orders Table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    status order_status NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method payment_method NOT NULL,
    is_paid BOOLEAN DEFAULT false,
    delivery_address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Order Items Table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity INT NOT NULL,
    price_at_time DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Returns Table
CREATE TABLE returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    status return_status NOT NULL DEFAULT 'requested',
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Reviews Table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    rating INT CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ROW LEVEL SECURITY (RLS) POLICIES

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Users: Users can read their own profile. Admins can read all.
CREATE POLICY "Users can view their own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- Shops: Anyone can read shops. Shopkeepers can manage their own shops.
CREATE POLICY "Anyone can view shops" ON shops FOR SELECT USING (true);
CREATE POLICY "Shopkeepers can insert their own shop" ON shops FOR INSERT WITH CHECK (auth.uid() = shopkeeper_id);
CREATE POLICY "Shopkeepers can update their own shop" ON shops FOR UPDATE USING (auth.uid() = shopkeeper_id);

-- Products: Anyone can read products. Shopkeepers manage their own products.
CREATE POLICY "Anyone can view products" ON products FOR SELECT USING (true);
CREATE POLICY "Shopkeepers can manage products" ON products FOR ALL USING (
    auth.uid() IN (SELECT shopkeeper_id FROM shops WHERE id = shop_id)
);

-- Orders: Customers can see their orders. Shopkeepers can see orders for their shop.
CREATE POLICY "Customers can view their own orders" ON orders FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY "Shopkeepers can view their shop orders" ON orders FOR SELECT USING (
    auth.uid() IN (SELECT shopkeeper_id FROM shops WHERE id = shop_id)
);
CREATE POLICY "Customers can insert orders" ON orders FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "Shopkeepers can update order status" ON orders FOR UPDATE USING (
    auth.uid() IN (SELECT shopkeeper_id FROM shops WHERE id = shop_id)
);

-- Order Items: Same visibility as orders.
CREATE POLICY "Users can view their order items" ON order_items FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM orders
        WHERE id = order_items.order_id
        AND (customer_id = auth.uid() OR auth.uid() IN (SELECT shopkeeper_id FROM shops WHERE id = orders.shop_id))
    )
);
CREATE POLICY "Customers can insert order items" ON order_items FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM orders WHERE id = order_items.order_id AND customer_id = auth.uid())
);

-- Returns: Customers see their returns. Shopkeepers see their shop's returns.
CREATE POLICY "Customers can view their returns" ON returns FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY "Shopkeepers can view their shop returns" ON returns FOR SELECT USING (
    auth.uid() IN (SELECT shopkeeper_id FROM shops WHERE id = shop_id)
);
CREATE POLICY "Customers can insert returns" ON returns FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "Shopkeepers can update return status" ON returns FOR UPDATE USING (
    auth.uid() IN (SELECT shopkeeper_id FROM shops WHERE id = shop_id)
);

-- Reviews: Anyone can view. Customers can insert for their own purchases.
CREATE POLICY "Anyone can view reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Customers can insert reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = customer_id);
