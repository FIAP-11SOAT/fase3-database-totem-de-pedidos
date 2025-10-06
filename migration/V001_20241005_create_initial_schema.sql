create table if not exists payments (
    id bigserial primary key,
    amount numeric(12, 2) not null check (amount >= 0),
    payment_date timestamp not null default current_timestamp,
    status varchar(30) not null check (status in ('PENDING','PAID','FAILED','REFUNDED')),
    provider varchar(50) not null,
    transaction_code varchar(100) unique,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp not null default current_timestamp
);

create index if not exists idx_payments_status on payments (status);
create index if not exists idx_payments_provider on payments (provider);
create index if not exists idx_payments_date on payments (payment_date);

create table if not exists orders (
    id bigserial primary key,
    order_date timestamp not null default current_timestamp,
    notification_attempts int not null default 0 check (notification_attempts >= 0),
    status varchar(30) not null check (status in ('NEW','CONFIRMED','PREPARING','SHIPPED','DELIVERED','CANCELLED')),
    total_amount numeric(12, 2) not null check (total_amount >= 0),
    customer_id varchar(255),
    payment_id bigint references payments (id) on delete set null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp not null default current_timestamp
);

create index if not exists idx_orders_payment_id on orders (payment_id);
create index if not exists idx_orders_status on orders (status);
create index if not exists idx_orders_date on orders (order_date);

create table if not exists product_categories (
    id bigserial primary key,
    name varchar(100) not null unique,
    description text,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp not null default current_timestamp
);

create index if not exists idx_product_categories_created_at on product_categories (created_at);

create table if not exists products (
    id bigserial primary key,
    name varchar(150) not null unique,
    description text,
    price numeric(12, 2) not null check (price >= 0),
    image_url varchar(500),
    preparation_time int not null check (preparation_time >= 0),
    category_id bigint not null references product_categories (id) on delete restrict,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp not null default current_timestamp
);

create index if not exists idx_products_category_id on products (category_id);
create index if not exists idx_products_price on products (price);
create index if not exists idx_products_created_at on products (created_at);

create table if not exists order_items (
    id bigserial primary key,
    order_id bigint not null references orders (id) on delete cascade,
    product_id bigint not null references products (id) on delete restrict,
    quantity int not null check (quantity > 0),
    price numeric(12, 2) not null check (price >= 0),
    created_at timestamp not null default current_timestamp,
    updated_at timestamp not null default current_timestamp,
    unique (order_id, product_id)
);

create index if not exists idx_order_items_order_id on order_items (order_id);
create index if not exists idx_order_items_product_id on order_items (product_id);

insert into product_categories (name, description) values
('Lanche', 'Sanduíches e hambúrgueres'),
('Acompanhamento', 'Batatas, saladas e outros acompanhamentos'),
('Bebida', 'Refrigerantes, sucos e outras bebidas'),
('Sobremesa', 'Doces e sobremesas')
on conflict (name) do nothing;

insert into products (name, description, price, image_url, preparation_time, category_id) values
('Hambúrguer Clássico', 'Pão, carne, queijo, alface e tomate', 18.90, 'https://images.unsplash.com/photo-1550547660-d9450f859349', 15, 1),
('Cheeseburger Bacon', 'Hambúrguer com queijo e bacon crocante', 22.50, 'https://images.unsplash.com/photo-1553979459-d2229ba7433b', 18, 1),
('Batata Frita', 'Porção de batatas fritas crocantes', 9.90, 'https://images.unsplash.com/photo-1598679253544-2c97992403ea', 8, 2),
('Onion Rings', 'Anéis de cebola empanados', 11.50, 'https://images.unsplash.com/photo-1639024471283-03518883512d', 10, 2),
('Refrigerante Lata', '350ml - Coca-Cola, Guaraná ou Fanta', 6.00, 'https://images.unsplash.com/photo-1527960471264-932f39eb5846', 2, 3),
('Suco Natural', 'Suco de laranja ou limão', 7.50, 'https://images.unsplash.com/photo-1600271886742-f049cd451bba', 3, 3),
('Sorvete', 'sorvete', 14.00, 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f', 7, 4),
('Petit Gateau', 'Bolo de chocolate com recheio cremoso e sorvete', 16.00, 'https://t4.ftcdn.net/jpg/02/21/31/01/240_F_221310131_cUVS5tnUMG1qv3GWzzj8w2bgDUtLSmRv.jpg', 10, 4)
on conflict (name) do nothing;
