INSERT INTO proprietario(nif, nome, genero, piso ,letra)
	VALUES(100000001,'abc','M',3,'A');
--
INSERT INTO administra(proprietario,ano )
	VALUES(100000001, 2015);
--
INSERT INTO administra(proprietario,ano )
	VALUES(100000001, 2005);
--
INSERT INTO proprietario(nif, nome, genero, piso ,letra)
	VALUES(100000002,'abcd','M',4,'A');
--
INSERT INTO administra(proprietario,ano )
	VALUES(100000002, 2001);
--
INSERT INTO proprietario(nif, nome, genero, piso ,letra)
	VALUES(100000003,'abcde','F',6,'A');
--
INSERT INTO administra(proprietario,ano )
	VALUES(100000003, 2016);
--
INSERT INTO proprietario(nif, nome, genero, piso ,letra)
	VALUES(100000004,'Pabcde','F',7,'A');
--
INSERT INTO administra(proprietario,ano )
	VALUES(100000004, 2015);
--
INSERT INTO contrato (numero, empresa, equipamento, ano, euros)
     VALUES (54323, 'Anti Fogos, Lda.', 'Extintores', 2001, 6000.0);
---
INSERT INTO autoriza (administrador, ano, contrato)
    VALUES(100000002, 2001, 54323);
--
INSERT INTO autoriza (administrador, ano, contrato)
    VALUES(100000003, 2016, 54325);
--
INSERT INTO contrato (numero, empresa, equipamento, ano, euros)
     VALUES (54322, 'Desce e Sobe, Lda.', 'Elevadores', 2015, 4000.0);
--
INSERT INTO contrato (numero, empresa, equipamento, ano, euros)
     VALUES (54324, 'asdkjaç', 'Extintores', 2015, 4000.0);
--
INSERT INTO contrato (numero, empresa, equipamento, ano, euros)
     VALUES (54325, 'asdaç', 'Extintores', 2016, 4000.0);
--
INSERT INTO autoriza (administrador, ano, contrato)
    VALUES(100000004, 2015, 54322);
--
INSERT INTO autoriza (administrador, ano, contrato)
    VALUES(100000004, 2015, 54324);
--
INSERT INTO autoriza (administrador, ano, contrato)
    VALUES(100000001, 2015, 54324);
--
