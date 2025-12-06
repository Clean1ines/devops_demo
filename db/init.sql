-- Создаем таблицы для промышленных объектов
CREATE TABLE IF NOT EXISTS industrial_objects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создаем таблицу для оборудования
CREATE TABLE IF NOT EXISTS equipment (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    object_id INTEGER REFERENCES industrial_objects(id),
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Вставляем тестовые данные
INSERT INTO industrial_objects (name, type, location) VALUES
('Белоярская АЭС', 'АЭС', 'Свердловская область'),
('Сургутская ГРЭС-2', 'ТЭЦ', 'ХМАО-Югра'),
('Нововоронежская АЭС', 'АЭС', 'Воронежская область')
ON CONFLICT DO NOTHING;

INSERT INTO equipment (name, object_id, status) VALUES
('Турбина Т-250', 1, 'operational'),
('Генератор ГСВ-1500', 1, 'operational'),
('Котел КВГМ-100', 2, 'operational'),
('Турбогенератор ТВВ-500', 2, 'operational'),
('Реактор ВВЭР-1000', 3, 'operational'),
('Турбоустановка К-1000', 3, 'operational')
ON CONFLICT DO NOTHING;

-- Создаем роль для LDAP аутентификации (критично для Neolant enterprise)
CREATE ROLE ldap_auth WITH LOGIN PASSWORD 'ldap_secure_password_2025';
GRANT CONNECT ON DATABASE neolant_db TO ldap_auth;
GRANT SELECT ON industrial_objects TO ldap_auth;
GRANT SELECT ON equipment TO ldap_auth;

-- Добавляем комментарий для документации
COMMENT ON ROLE ldap_auth IS 'Enterprise LDAP authentication role for industrial systems';
