/*
NIF e nome dos proprietários que foram administradores depois de 2000, e o piso e letra dos seus
apartamentos. O resultado deve vir ordenado pelo piso e letra de forma descendente. Nota: pretende-se
uma interrogação com apenas um SELECT.
*/

SElECT P.nif, P.nome, P.piso, P.letra
	FROM proprietario P, administra AD
	WHERE(P.nif = AD.proprietario)
	AND(AD.ano > 2000)
	ORDER BY P.piso DESC, P.letra DESC;
	
	

/*
	NIF e nome dos proprietários que foram administradores em, pelo menos, um ano entre 2000 e
2010, ou então que sejam do género feminino e tenham apartamentos acima do piso 5. Nota: pode
usar construtores de conjuntos.
*/

SElECT DISTINCT P.nif, P.nome
	FROM proprietario P, administra AD
	WHERE(P.nif = AD.proprietario)
	AND(AD.ano BETWEEN 2000 AND 2010)
	UNION
SELECT P.nif, P.nome
	FROM proprietario P
	WHERE(P.genero = 'F')
	AND(P.piso > 5);
	
/*Nome das empresas com contratos de manutenção de elevadores entre 2010 e 2015 que foram
autorizados por, pelo menos, uma administradora com nome começado por ‘P’.	*/


SELECT DISTINCT C.empresa
	FROM contrato C, proprietario P, autoriza A
	WHERE(C.numero = A.contrato)
	AND (P.nif = A.administrador)
	AND (C.equipamento = 'Elevadores')
	AND( C.ano BETWEEN 2010 AND 2015)
	AND( P.genero = 'F')
	AND( P. nome LIKE 'P%');
	

/*
NIF e nome dos administradores de género masculino que nunca autorizaram contratos com empresas
de manutenção de extintores com valor acima dos 5000 euros.
*/

SELECT DISTINCT P.nif, P.nome
  FROM  proprietario P, autoriza A
  WHERE (A.administrador = P.nif)
  AND (P.genero = 'M')
  AND (A.contrato NOT IN(SELECT C.numero
							FROM contrato C
							WHERE (C.equipamento = 'Extintores')
							AND(C.euros > 5000)
							));
							
/*
Nome das empresas, tipos de equipamento, ano, e euros dos contratos de manutenção que tenham
sido autorizados por todos os administradores do ano de vigência do contrato. Nota: o resultado
deve vir ordenado pelo ano e valor em euros de forma descendente, e pelo tipo de equipamento e
nome da empresa de forma ascendente.
*/


SELECT C.empresa, C.equipamento,C.ano,C.euros
FROM contrato C
WHERE (NOT EXISTS( SELECT *
					FROM administra A
					WHERE A.ano = C.ano
					AND(A.proprietario  NOT IN ( SELECT AT.administrador
						                FROM  autoriza AT
										WHERE (AT.contrato = C.numero)))))
ORDER BY C.ano DESC, C.euros DESC, C.equipamento ASC, C.empresa ASC;


/*
Soma dos euros e respetivo valor de IVA à taxa de 6% dos contratos de manutenção autorizados
por cada administrador, em cada ano. Nota: o resultado deve vir ordenado pelo NIF e nome do
administrador de forma ascendente, e pelo ano de forma descendente. 
*/
-- Perguntar Profesor: Deve aparecer 0 se o administrador não tiver autorizado nenhum contrato nesse ano?

SELECT P.nif, P.nome, A.ano, SUM(C.euros) AS Total, SUM(C.euros)*0.06 AS IVA
FROM proprietario P,administra A, contrato C, autoriza AT
WHERE (P.nif = A.proprietario)
AND ( A.proprietario = AT.administrador)
AND (AT.contrato = C.numero)
AND ( AT.ano = A.ano)
GROUP BY P.nif,P.nome, A.ano
ORDER BY A.ano DESC,P.nif ASC,P.nome ASC;

/*
NIF e nome dos administradores com maior quantidade de autorizações de contratos de manuten-
ção para cada ano. Notas: em caso de empate, devem ser mostrados todos os administradores em
causa. O resultado deve vir ordenado pelo ano de forma descendente, e pelo NIF e nome dos
administradores de forma ascendente.
*/


SELECT 	P.nif, P.nome, A.ano, COUNT(C.numero) AS Contratos_Aut
FROM proprietario P,administra A, contrato C, autoriza AT
WHERE (P.nif = A.proprietario)
AND ( A.proprietario = AT.administrador)
AND (AT.contrato = C.numero)
AND ( AT.ano = A.ano)
GROUP BY P.nif,P.nome, A.ano
HAVING COUNT(C.numero) >= ALL (SELECT COUNT(C1.numero)
								FROM contrato C1, autoriza AT1
								WHERE (AT1.contrato = C1.numero)
								GROUP BY AT1.administrador, AT1.ano
								HAVING AT1.ano = A.ano)
ORDER BY A.ano DESC,P.nif ASC,P.nome ASC;


/*
8. Para cada género, o NIF e nome do/a proprietário/a que foi mais vezes administrador/a, incluindo
o número total de anos, o primeiro ano, e o último ano. Nota: em caso de empate do total de anos,
devem ser mostrados/as todos/as os/as administradores/as em causa.
*/


SELECT P0.nome, P0.nif, P0.genero, T.Ultimo_Ano, T.Primeiro_Ano,T.Anos	
FROM (SELECT A0.proprietario AS nif, MAX(A0.ano) AS Ultimo_Ano, MIN(A0.ano) AS Primeiro_Ano, COUNT(A0.ano) AS Anos	
	 FROM administra A0	
     WHERE(A0.proprietario IN(SELECT 	P.nif
					FROM proprietario P,administra A
					WHERE (P.nif = A.proprietario)
					GROUP BY P.nif,P.genero
					HAVING COUNT(P.nif) >= ALL(SELECT COUNT(A1.ano)
											FROM proprietario P1,administra A1
											WHERE (P1.nif = A1.proprietario)
											GROUP BY  P1.nif,P1.genero
											HAVING P1.genero = P.genero)))
	GROUP BY A0.proprietario) T, proprietario P0
WHERE (T.nif = P0.nif)
ORDER BY P0.genero;
											





