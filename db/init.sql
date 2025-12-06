CREATE TABLE IF NOT EXISTS industrial_objects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100),
    location TEXT
);

INSERT INTO industrial_objects (name, type, location) VALUES 
('Белоярская АЭС', 'АЭС', 'Свердловская область'),
('Сургутская ГРЭС-2', 'ТЭЦ', 'ХМАО-Югра'),
('Нововоронежская АЭС', 'АЭС', 'Воронежская область');
