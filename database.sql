
/* component tabel */
CREATE TABLE component
(
  id            SERIAL PRIMARY KEY,
  component_id  SERIAL,
  name          character varying NOT NUll,
  kind          character varying NOT NUll,
  price         numeric NOT NUll
)
WITH (
  OIDS=FALSE
);
ALTER TABLE component
  OWNER TO postgres;
  

/* computer system tabel */
CREATE TABLE computer_system
(
  cs_id       SERIAL,
  name        character varying NOT NULL,
  kind        character varying NOT NULL,
  cpu         numeric NOT NUll,
  mainboard   numeric NOT NUll,
  ram         numeric NOT NUll,
  cabine      numeric NOT NUll,
  gfx         numeric,
 CONSTRAINT computer_system_pkey PRIMARY KEY (cs_id),
  CONSTRAINT cs_id_fkey FOREIGN KEY (cs_id)
      REFERENCES component (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE computer_system
  OWNER TO postgres;


/* CPU tabel */
CREATE TABLE cpu
(
  id              SERIAL ,
  socket          character varying NOT NUll,
  bus_speed_cpu   integer NOT NUll
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cpu
  OWNER TO postgres;


/* GFX tabel */
CREATE TABLE graphics_card
(
  id              SERIAL,
  bus_speed_gfx   numeric NOT NUll

)
WITH (
  OIDS=FALSE
);
ALTER TABLE graphics_card
  OWNER TO postgres;


/* mainboard tabel */
CREATE TABLE mainboard
(
  id              SERIAL,
  cpu_socket      character varying NOT NUll,
  ram_type        character varying NOT NUll,
  gpu_on_board    boolean,
  formfactor_mb   character varying NOT NUll
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE mainboard
  OWNER TO postgres;


/* RAM tabel */
CREATE TABLE ram
(
  id              SERIAL,
  ram_type        character varying NOT NUll,
  bus_speed_ram   integer NOT NUll
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ram
  OWNER TO postgres;


/* case tabel */
CREATE TABLE cabine
(
  id                SERIAL,
  formfactor_case   character varying NOT NUll
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cabine
  OWNER TO postgres;

  /* stock tabel */
CREATE TABLE stock
(
  id                SERIAL,  
  current_stock     numeric NOT NULL,
  preferred_amount  numeric NOT NUll,
  minimum_amount    numeric NOT NUll,
  CONSTRAINT stock_pkey PRIMARY KEY (id),

  CONSTRAINT stock_id_fkey FOREIGN KEY (id)
      REFERENCES component (id)
  
 )
WITH (
  OIDS=FALSE
);
ALTER TABLE stock
  OWNER TO postgres;


/* CPU View */
CREATE VIEW cpu_view AS SELECT 
id , name, kind, price, socket, bus_speed_cpu 
FROM cpu NATURAL JOIN component; 

/* mb View */
CREATE VIEW mb_view AS SELECT 
id, name, kind, price, cpu_socket, ram_type, gpu_on_board, formfactor_mb
FROM mainboard NATURAL JOIN component ;

/* RAM View */
CREATE VIEW ram_view AS SELECT 
id, name, kind, price, ram_type, bus_speed_ram 
FROM ram NATURAL JOIN component;

/* GFX View*/
CREATE VIEW gfx_view AS SELECT 
id, name, kind, price, bus_speed_gfx
FROM graphics_card NATURAL JOIN component;

/* Case View*/
CREATE VIEW cabine_view AS SELECT 
id, name, kind, price, formfactor_case
FROM cabine NATURAL JOIN component;

CREATE VIEW stock_view AS SELECT 
id, name, kind, price, current_stock, preferred_amount, minimum_amount
FROM stock NATURAL JOIN component ;



CREATE VIEW computer_system_view AS 
(SELECT computer_system.cs_id, computer_system.name, computer_system.kind, 
(SELECT name FROM component WHERE CAST(component.id AS NUMERIC) = computer_system.cpu) AS cpu,
(SELECT name FROM component WHERE CAST(component.id AS NUMERIC) = computer_system.mainboard) AS mainboard,
(SELECT name FROM component WHERE CAST(component.id AS NUMERIC) = computer_system.ram) AS ram,
(SELECT name FROM component WHERE CAST(component.id AS NUMERIC) = computer_system.cabine) AS cabine,
(SELECT name FROM component WHERE CAST(component.id AS NUMERIC) = computer_system.gfx) AS gpu,
(SELECT SUM(price) FROM component WHERE 
      CAST(component.id AS NUMERIC) = computer_system.cpu OR 
      CAST(component.id AS NUMERIC) = computer_system.ram OR 
      CAST(component.id AS NUMERIC) = computer_system.mainboard OR 
      CAST(component.id AS NUMERIC) = computer_system.cabine OR 
      CAST(component.id AS NUMERIC) = computer_system.gfx) AS price,
(SELECT MIN(current_stock) FROM stock WHERE 
stock.id = computer_system.cpu OR 
stock.id = computer_system.mainboard OR 
stock.id = computer_system.ram OR 
stock.id = computer_system.cabine OR 
stock.id = computer_system.gfx) AS current_stock
FROM computer_system);

/*
  Fucntions 
*/
CREATE FUNCTION t_check() RETURNS TRIGGER AS $$
  BEGIN 
  IF ((SELECT gpu_on_board FROM mainboard WHERE NEW.mainboard = mainboard.id) IS FALSE AND 
  (NEW.gfx IS NULL)) THEN   
    RAISE EXCEPTION 'NO grafics-card';
     END IF;
  IF ((SELECT socket FROM cpu WHERE NEW.cpu = cpu.id) != 
    (SELECT cpu_socket FROM mainboard WHERE NEW.mainboard = mainboard.id)) THEN
    RAISE EXCEPTION 'NO matching cpu socket';
  END IF; 
  IF ((SELECT ram_type FROM mainboard WHERE NEW.mainboard = mainboard.id) != 
    (SELECT ram_type FROM ram WHERE NEW.ram = ram.id)) THEN
    RAISE EXCEPTION 'NO matching RAM type';
  END IF; 
    IF ((SELECT formfactor_mb FROM mainboard WHERE NEW.mainboard = mainboard.id) != 
    (SELECT formfactor_case FROM cabine WHERE NEW.cabine = cabine.id)) THEN
    RAISE EXCEPTION 'NO matching formfactor';
  END IF; 
  IF ((SELECT formfactor_mb FROM mainboard WHERE NEW.mainboard = mainboard.id) != 
    (SELECT formfactor_case FROM cabine WHERE NEW.cabine = cabine.id)) THEN
    RAISE EXCEPTION 'NO matching formfactor';
  END IF;
  RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_check
  AFTER UPDATE OR INSERT ON computer_system 
  FOR EACH ROW
  EXECUTE PROCEDURE t_check ();


/*  
  RULES for insert 
*/

CREATE RULE cpu_insert_rule AS
    ON INSERT TO cpu_view
        DO INSTEAD (
            INSERT INTO component VALUES
            (DEFAULT, DEFAULT, NEW.name, 'cpu', ((ROUND(NEW.price*1.3,-2))-1));
 
            INSERT INTO cpu VALUES
            ((SELECT id FROM component WHERE name = NEW.name),
            NEW.socket, NEW.bus_speed_cpu);

);

CREATE RULE mb_insert_rule AS
    ON INSERT TO mb_view
        DO INSTEAD (
            INSERT INTO component VALUES
            (DEFAULT, DEFAULT, NEW.name, 'mainboard', ((ROUND(NEW.price*1.3, -2))-1));
 
            INSERT INTO mainboard VALUES
            ((SELECT id FROM component WHERE name = NEW.name),
            NEW.cpu_socket, NEW.ram_type, NEW.gpu_on_board, NEW.formfactor_mb);
);

CREATE RULE ram_insert_rule AS
    ON INSERT TO ram_view
        DO INSTEAD ( 
            INSERT INTO component VALUES
            (DEFAULT, DEFAULT, NEW.name, 'ram', ((ROUND(NEW.price*1.3, -2))-1));
 
            INSERT INTO ram VALUES
            ((SELECT id FROM component WHERE name = NEW.name),
            NEW.ram_type, NEW.bus_speed_ram);
);

CREATE RULE gfx_insert_rule AS
    ON INSERT TO gfx_view
        DO INSTEAD ( 
            INSERT INTO component VALUES
            (DEFAULT, DEFAULT, NEW.name, 'gfx', ((ROUND(NEW.price*1.3, -2))-1));
 
            INSERT INTO graphics_card VALUES
            ((SELECT id FROM component WHERE name = NEW.name),
            NEW.bus_speed_gfx);
);

CREATE RULE cabine_insert_rule AS
    ON INSERT TO cabine_view
        DO INSTEAD ( 
            INSERT INTO component VALUES
            (DEFAULT, DEFAULT, NEW.name, 'case', ((ROUND(NEW.price*1.3,-2))-1));
 
            INSERT INTO cabine VALUES
            ((SELECT id FROM component WHERE name = NEW.name),
            NEW.formfactor_case);
);

CREATE RULE stock_insert_rule AS
    ON INSERT TO stock_view
        DO INSTEAD ( 
            INSERT INTO stock VALUES
            (DEFAULT, NEW.current_stock, NEW.preferred_amount, NEW.minimum_amount);
            
);


/*            INEVENTROY DATA         
*/

/* CPU */

INSERT INTO cpu_view VALUES
(DEFAULT, 'Intel - Core i5 6600K', 'cpu', 2195, 'LGA1151', 3500),
(DEFAULT, 'Intel - Pentium G3250', 'cpu', 539, 'LGA1150', 3200),
(DEFAULT,  'AMD - Pentium G3250', 'cpu', 1200, 'AM3+', 3500),
(DEFAULT, 'AMD - Athlon X4 840', 'cpu', 529, 'FM2+', 3100),
(DEFAULT, 'Intel - Core i3-6100', 'cpu', 1099, 'LGA1151', 3700),
(DEFAULT, 'Intel - Core i7-5960X Extreme', 'cpu', 8690, 'LGA2011-v3', 3000),
(DEFAULT, 'Intel - Core i5-6400', 'cpu', 1549, 'LGA1151', 2700);


/* MotherBoards */

INSERT INTO mb_view VALUES
(DEFAULT, 'ASUS - Z170-P', 'mainboard', 1049, 'LGA1151', 'DDR4', 'TRUE', 'ATX'),
(DEFAULT, 'Gigabyte - GA-Z170-Gaming K3', 'mainboard', 999, 'LGA1151', 'DDR4', 'TRUE', 'ATX'),
(DEFAULT, 'ASUS - H81I-PLUS', 'mainboard', 599, 'LGA1150', 'DDR3', 'TRUE', 'mini-ITX'),
(DEFAULT, 'ASUS - M5A97 R2.0', 'mainboard', 749, 'AM3+', 'DDR3', 'TRUE', 'ATX'),
(DEFAULT, 'MSI - A68HM GRENADE', 'mainboard', 479, 'FM2+', 'DDR3', 'TRUE', 'ATX'),
(DEFAULT, 'ASUS - B150M-A', 'mainboard', 699, 'LGA1151', 'DDR4', 'TRUE', 'ATX'),
(DEFAULT, 'MSI - X99A GAMING 9 ACK', 'mainboard', 3599, 'LGA2011-v3', 'DDR4', 'TRUE', 'EATX'),
(DEFAULT, 'ASUS - B150M Pro Gaming', 'mainboard', 899, 'LGA1151', 'DDR4', 'FALSE', 'ATX'); 

/* RAM */

INSERT INTO ram_view VALUES
(DEFAULT, 'Kingston - Value 2133MHz','ram', 299, 'DDR4', 8192),
(DEFAULT, 'Kingston - HyperX Fury 2133MHz','ram', 379, 'DDR4', 8192),
(DEFAULT, 'Kingston - HyperX Fury 1866MHz','ram', 349, 'DDR3', 8192),
(DEFAULT, 'Kingston - HyperX Fury 2100MHz','ram', 1199, 'DDR4', 32768),
(DEFAULT, 'Crucial - 2133MHz','ram', 299, 'DDR4', 8192); 

 /* Case */

INSERT INTO cabine_view VALUES
(DEFAULT, 'Corsair - Carbide 330R Blackout Edition','case', 790, 'ATX'),
(DEFAULT, 'Corsair - Carbide 200R','case', 549, 'ATX'),
(DEFAULT, 'Cooler Master - Elite 120','case', 449, 'mini-ITX'),
(DEFAULT, 'In Win - 703','case', 599, 'ATX'),
(DEFAULT, 'Corsair - Graphite 760T','case', 1399, 'EATX'),
(DEFAULT,'Corsair - Carbide SPEC-03','case', 649, 'ATX');

/* Graphic Card */

INSERT INTO gfx_view VALUES
(DEFAULT, 'ASUS - GeForce GTX 970','gfx', 2590, '3500'),
(DEFAULT, 'Gainward - GeForce GTX 960','gfx', 1590, '3200'),
(DEFAULT,'XFX - Radeon R9 380','gfx', 1399, '3500'),
(DEFAULT, 'XFX - Radeon R7 360','gfx', 949, '3100'),
(DEFAULT, 'MSI - GeForce GTX TITAN X','gfx', 8395, '4000'),
(DEFAULT,'ASUS - TURBO GeForce GTX960','gfx', 1799, '2133'); 

/* Stock */

INSERT INTO stock_view VALUES
 (DEFAULT,'Intel - Core i5 6600K', DEFAULT,DEFAULT,                  100,    150,    50),
 (DEFAULT,'Intel - Pentium G3250', DEFAULT,DEFAULT,                  100,    150,    50),
 (DEFAULT,'Intel - Core i3-6100', DEFAULT,DEFAULT,                   100,    150,    50),
 (DEFAULT,'Intel - Core i7-5960X Extreme', DEFAULT,DEFAULT,          100,    150,    50),
 (DEFAULT,'Intel - Core i5-6400', DEFAULT,DEFAULT,                   100,    150,    50),
 (DEFAULT,'AMD - FX-8320 Black Edition', DEFAULT,DEFAULT,            100,    150,    50),
 (DEFAULT,'AMD - Athlon X4 840', DEFAULT,DEFAULT,                    100,    150,    50),
 (DEFAULT,'Kingston - Value 8GB', DEFAULT,DEFAULT,                   100,    150,    50),
 (DEFAULT,'Kingston - HyperX Fury-3 8GB', DEFAULT,DEFAULT,           100,    150,    50),
 (DEFAULT,'Kingston - HyperX Fury-4 8GB', DEFAULT,DEFAULT,           100,    150,    50),
 (DEFAULT,'Kingston - HyperX Fury-4 32GB', DEFAULT,DEFAULT,          100,    150,    50),
 (DEFAULT,'Crucial - 8GB', DEFAULT,DEFAULT,                          100,    150,    50),
 (DEFAULT,'Gainward - GeForce GTX 960', DEFAULT,DEFAULT,             100,    150,    50),
 (DEFAULT,'XFX - Radeon R9 380', DEFAULT,DEFAULT,                    100,    150,    50),
 (DEFAULT,'XFX - Radeon R7 360', DEFAULT,DEFAULT,                    100,    150,    50),
 (DEFAULT,'MSI - GeForce GTX TITAN X', DEFAULT,DEFAULT,              100,    150,    50),
 (DEFAULT,'ASUS - GeForce GTX 970', DEFAULT,DEFAULT,                 100,    150,    50),
 (DEFAULT,'ASUS - TURBO GeForce GTX960', DEFAULT,DEFAULT,            100,    150,    50),
 (DEFAULT,'Gigabyte - GA-Z170-Gaming K3', DEFAULT,DEFAULT,           100,    150,    50),
 (DEFAULT,'ASUS - Z170-P', DEFAULT,DEFAULT,                          100,    150,    50),
 (DEFAULT,'ASUS - H81I-PLUS', DEFAULT,DEFAULT,                       100,    150,    50),
 (DEFAULT,'ASUS - M5A97 R2.0', DEFAULT,DEFAULT,                      100,    150,    50),
 (DEFAULT,'ASUS - B150M-A', DEFAULT,DEFAULT,                         100,    150,    50),
 (DEFAULT,'ASUS - B150M Pro Gaming', DEFAULT,DEFAULT,                100,    150,    50),
 (DEFAULT,'MSI - A68HM GRENADE', DEFAULT,DEFAULT,                    100,    150,    50),
 (DEFAULT,'MSI - X99A GAMING 9 ACK', DEFAULT,DEFAULT,                100,    150,    50), 
 (DEFAULT,'Corsair - Carbide 330R Blackout Edition', DEFAULT,DEFAULT,100,    150,    50),
 (DEFAULT,'Corsair - Carbide 200R', DEFAULT,DEFAULT,                 100,    150,    50),
 (DEFAULT,'Corsair - Graphite 760T', DEFAULT,DEFAULT,                100,    150,    50),
 (DEFAULT,'Corsair - Carbide SPEC-03', DEFAULT,DEFAULT,              100,    150,    50),
 (DEFAULT,'Cooler Master - Elite 120', DEFAULT,DEFAULT,              100,    150,    50),
 (DEFAULT,'In Win - 703', DEFAULT,DEFAULT,                           100,    150,    50);



INSERT INTO computer_system VALUES
(DEFAULT,'Super awesome computer','computer system', 1, 8, 16, 21, 27),
(DEFAULT,'Super noob computer','computer system', 6, 14, 19, 25, 31),
(DEFAULT,'Super bitcoin farm computer','computer system', 2, 10, 18, 23, 28),
(DEFAULT,'Super duper noober computer','computer system', 7, 9, 20, 24, NULL),
(DEFAULT,'Super assjack computer','computer system', 5, 15, 17, 26, 30),
(DEFAULT,'Super magnificant computer','computer system', 5, 8, 16, 21, 29),
(DEFAULT,'Super moppet computer','computer system', 4, 12, 18, 22, 30),
(DEFAULT,'Super cracker-hacker-firecracker computer','computer system', 3, 11, 18, 21, 29);
