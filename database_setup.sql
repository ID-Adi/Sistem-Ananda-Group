-- Membuat tabel untuk transaksi akuntansi
CREATE TABLE IF NOT EXISTS accounting_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    description TEXT NOT NULL,
    amount NUMERIC(15, 2) NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    category TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membuat indeks untuk mempercepat pencarian berdasarkan user_id
CREATE INDEX IF NOT EXISTS accounting_transactions_user_id_idx ON accounting_transactions(user_id);

-- Membuat tabel untuk item inventory
CREATE TABLE IF NOT EXISTS inventory_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    quantity INTEGER NOT NULL DEFAULT 0,
    unit_price NUMERIC(15, 2) NOT NULL DEFAULT 0,
    category TEXT NOT NULL,
    min_stock_level INTEGER NOT NULL DEFAULT 0,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membuat indeks untuk mempercepat pencarian berdasarkan user_id
CREATE INDEX IF NOT EXISTS inventory_items_user_id_idx ON inventory_items(user_id);

-- Membuat tabel untuk kategori akuntansi
CREATE TABLE IF NOT EXISTS accounting_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membuat tabel untuk kategori inventory
CREATE TABLE IF NOT EXISTS inventory_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membuat tabel untuk supplier
CREATE TABLE IF NOT EXISTS suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    contact_person TEXT,
    phone TEXT,
    email TEXT,
    address TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membuat tabel untuk pelanggan
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    contact_person TEXT,
    phone TEXT,
    email TEXT,
    address TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membuat tabel untuk purchase orders (pembelian)
CREATE TABLE IF NOT EXISTS purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT NOT NULL,
    order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    total_amount NUMERIC(15, 2) NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'received', 'cancelled')),
    notes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membuat tabel untuk detail purchase order
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchase_order_id UUID REFERENCES purchase_orders(id) ON DELETE CASCADE,
    inventory_item_id UUID REFERENCES inventory_items(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    unit_price NUMERIC(15, 2) NOT NULL DEFAULT 0,
    total_price NUMERIC(15, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membuat tabel untuk sales orders (penjualan)
CREATE TABLE IF NOT EXISTS sales_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT NOT NULL,
    order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    total_amount NUMERIC(15, 2) NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'shipped', 'delivered', 'cancelled')),
    notes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membuat tabel untuk detail sales order
CREATE TABLE IF NOT EXISTS sales_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sales_order_id UUID REFERENCES sales_orders(id) ON DELETE CASCADE,
    inventory_item_id UUID REFERENCES inventory_items(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    unit_price NUMERIC(15, 2) NOT NULL DEFAULT 0,
    total_price NUMERIC(15, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Membuat trigger untuk otomatis mengupdate updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Menerapkan trigger ke tabel-tabel yang memiliki kolom updated_at
CREATE TRIGGER set_timestamp_inventory_items
BEFORE UPDATE ON inventory_items
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER set_timestamp_suppliers
BEFORE UPDATE ON suppliers
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER set_timestamp_customers
BEFORE UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER set_timestamp_purchase_orders
BEFORE UPDATE ON purchase_orders
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER set_timestamp_sales_orders
BEFORE UPDATE ON sales_orders
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Membuat kebijakan keamanan Row Level Security (RLS)
-- Mengaktifkan RLS pada semua tabel
ALTER TABLE accounting_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounting_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_order_items ENABLE ROW LEVEL SECURITY;

-- Membuat kebijakan untuk setiap tabel agar pengguna hanya dapat melihat dan mengedit data mereka sendiri
CREATE POLICY accounting_transactions_policy ON accounting_transactions
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY inventory_items_policy ON inventory_items
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY accounting_categories_policy ON accounting_categories
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY inventory_categories_policy ON inventory_categories
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY suppliers_policy ON suppliers
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY customers_policy ON customers
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY purchase_orders_policy ON purchase_orders
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY purchase_order_items_policy ON purchase_order_items
    USING (EXISTS (
        SELECT 1 FROM purchase_orders po
        WHERE po.id = purchase_order_items.purchase_order_id
        AND po.user_id = auth.uid()
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM purchase_orders po
        WHERE po.id = purchase_order_items.purchase_order_id
        AND po.user_id = auth.uid()
    ));

CREATE POLICY sales_orders_policy ON sales_orders
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY sales_order_items_policy ON sales_order_items
    USING (EXISTS (
        SELECT 1 FROM sales_orders so
        WHERE so.id = sales_order_items.sales_order_id
        AND so.user_id = auth.uid()
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM sales_orders so
        WHERE so.id = sales_order_items.sales_order_id
        AND so.user_id = auth.uid()
    ));

-- Membuat beberapa data contoh untuk kategori akuntansi
INSERT INTO accounting_categories (name, type, user_id)
VALUES 
('Penjualan', 'income', auth.uid()),
('Investasi', 'income', auth.uid()),
('Gaji', 'expense', auth.uid()),
('Sewa', 'expense', auth.uid()),
('Utilitas', 'expense', auth.uid()),
('Peralatan', 'expense', auth.uid());

-- Membuat beberapa data contoh untuk kategori inventory
INSERT INTO inventory_categories (name, user_id)
VALUES 
('Elektronik', auth.uid()),
('Furnitur', auth.uid()),
('Alat Tulis', auth.uid()),
('Peralatan Kantor', auth.uid());
