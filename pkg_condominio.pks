CREATE OR REPLACE PACKAGE pkg_condominio IS

  PROCEDURE regista_proprietario(
    nif_in        IN proprietario.nif%TYPE,
    nome_in       IN proprietario.nome%TYPE,
    genero_in     IN proprietario.genero%TYPE,
	piso_in		  IN proprietario.piso%TYPE,
	letra_in	  IN proprietario.letra%TYPE);
		
 --
  PROCEDURE regista_administrador (
    proprietario_in     IN administra.proprietario%TYPE,
    ano_in 				IN administra.ano%TYPE);

 -- 
  FUNCTION regista_contrato (
    empresa_in 			IN contrato.empresa%TYPE,
	equipamento_in		IN contrato.equipamento%TYPE,
	ano_in				IN contrato.ano%TYPE,
	euros_in			IN contrato.euros%TYPE)
	RETURN NUMBER;

 -- 
  PROCEDURE regista_autorizacao (
    administrador_in    IN autoriza.administrador%TYPE,
	ano_in				IN autoriza.ano%TYPE,
	contrato_in			IN autoriza.contrato%TYPE);
	
-- 
  PROCEDURE remove_proprietario(
    nif_in 			IN proprietario.nif%TYPE);

--
	PROCEDURE remove_administrador (
    proprietario_in		IN administra.proprietario%TYPE,
	ano_in				IN administra.ano%TYPE);
	
--
	PROCEDURE remove_contrato(
	numero_in 			IN contrato.numero%TYPE);
	
--
	PROCEDURE remove_autorizacao (
    administrador_in    IN autoriza.administrador%TYPE,
	ano_in				IN autoriza.ano%TYPE,
	contrato_in			IN autoriza.contrato%TYPE);
--


END pkg_condominio;
/