CREATE SEQUENCE seq_contrato
  INCREMENT BY 1 MAXVALUE 9999 NOCYCLE;

CREATE OR REPLACE PACKAGE BODY pkg_condominio IS

  -- --------------------------------------------------------------------------
  -- Cria um novo registo de proprietario.
  


 
  
  PROCEDURE regista_proprietario(
    nif_in        IN proprietario.nif%TYPE,
    nome_in       IN proprietario.nome%TYPE,
    genero_in     IN proprietario.genero%TYPE,
	piso_in		  IN proprietario.piso%TYPE,
	letra_in	  IN proprietario.letra%TYPE)
  IS
  BEGIN
    INSERT INTO proprietario(nif, nome, genero,piso,letra)
         VALUES (nif_in, nome_in, genero_in,piso_in,letra_in);

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20001, 'Já existe um proprietario ' ||
                                      'nesse apartamento.');

    WHEN OTHERS THEN RAISE;
  END regista_proprietario;
  
  
PROCEDURE regista_administrador (
    proprietario_in     IN administra.proprietario%TYPE,
    ano_in 				IN administra.ano%TYPE)
 IS
  adm_count number;
 BEGIN
   
	SELECT count(*) into adm_count 
	FROM administra 
	WHERE administra.ano = ano_in;
	
		IF (adm_count < 2) THEN
			INSERT INTO administra(proprietario,ano)
				VALUES (proprietario_in,ano_in);
		ELSE 
			RAISE_APPLICATION_ERROR(-20004, 'Já existem dois administradores para este ano');
		END IF;
	
	EXCEPTION
     WHEN OTHERS THEN
      BEGIN
        IF (SQLCODE = -2291) THEN
          RAISE_APPLICATION_ERROR(-20002, 'Proprietario tem de existir');
        END IF;
        RAISE;
      END;
  END regista_administrador;
  
 FUNCTION regista_contrato (
    empresa_in 			IN contrato.empresa%TYPE,
	equipamento_in		IN contrato.equipamento%TYPE,
	ano_in				IN contrato.ano%TYPE,
	euros_in			IN contrato.euros%TYPE)
    RETURN NUMBER
	IS 
	contrato_num NUMBER;
 BEGIN
	SELECT seq_contrato.NEXTVAL into contrato_num FROM dual;
		INSERT INTO contrato(numero,empresa,equipamento,ano,euros)
			VALUES (contrato_num,empresa_in,equipamento_in,ano_in,euros_in);
	RETURN contrato_num;
	EXCEPTION
	 WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20001, 'Já existe um contrato para esse equipamento neste ano ');
     WHEN OTHERS THEN
      BEGIN
        IF (SQLCODE = -2291) THEN
          RAISE_APPLICATION_ERROR(-20002, 'Proprietario tem de existir');
        END IF;
        RAISE;
      END;
  END regista_contrato;
	
 PROCEDURE regista_autorizacao (
    administrador_in    IN autoriza.administrador%TYPE,
	ano_in				IN autoriza.ano%TYPE,
	contrato_in			IN autoriza.contrato%TYPE)
  	IS
	 ano_contrato number;
   BEGIN
 
   SELECT contrato.ano into ano_contrato
	FROM contrato
   WHERE contrato.numero = contrato_in;

   IF (ano_contrato = ano_in) THEN
	INSERT INTO autoriza(administrador,ano,contrato)
			VALUES (administrador_in,ano_in,contrato_in);
	ELSE 
		RAISE_APPLICATION_ERROR(-20005, 'O ano do contrato tem de coincidir com o ano dado');
   END IF;
	EXCEPTION
     WHEN OTHERS THEN
      BEGIN
        IF (SQLCODE = -2291) THEN
          RAISE_APPLICATION_ERROR(-20002, 'Adminstrador tem de existir no ano indicado e contrato tem de existir');
        END IF;
        RAISE;
      END;
  END regista_autorizacao;

	


  -- --------------------------------------------------------------------------
  -- Remove um proprietario já existente.
   PROCEDURE remove_proprietario(
    nif_in 			IN proprietario.nif%TYPE)
  IS
    CURSOR cursor_administradores IS SELECT administra.ano FROM administra WHERE (administra.proprietario = nif_in);
    TYPE tabela_local_administradores IS TABLE OF cursor_administradores%ROWTYPE;
	
	administradores tabela_local_administradores;
  BEGIN
  
	 OPEN cursor_administradores;
    FETCH cursor_administradores BULK COLLECT INTO administradores;
    CLOSE cursor_administradores;
	
	
	IF (administradores.COUNT > 0) THEN
      FOR posicao_atual IN administradores.FIRST .. administradores.LAST LOOP
        pkg_condominio.remove_administrador(nif_in, administradores(posicao_atual).ano);
      END LOOP;
    END IF;

	DELETE FROM proprietario WHERE (proprietario.nif = nif_in);
	
    IF (SQL%ROWCOUNT = 0) THEN
      -- Nenhuma linha foi afetada pelo comando DELETE.
      RAISE_APPLICATION_ERROR(-20006, 'Proprietario a remover não existe.');
	  
    END IF;

  EXCEPTION
    WHEN OTHERS THEN RAISE;
  END remove_proprietario;

PROCEDURE remove_administrador (
    proprietario_in		IN administra.proprietario%TYPE,
	ano_in				IN administra.ano%TYPE)
	
	IS
    CURSOR cursor_autorizacoes IS SELECT autoriza.contrato FROM autoriza WHERE (autoriza.administrador = proprietario_in) AND (autoriza.ano = ano_in)  ;
    TYPE tabela_local_autorizacoes IS TABLE OF cursor_autorizacoes%ROWTYPE;
	
	autorizacoes tabela_local_autorizacoes;
  BEGIN
  
	 OPEN cursor_autorizacoes;
    FETCH cursor_autorizacoes BULK COLLECT INTO autorizacoes;
    CLOSE cursor_autorizacoes;
	
	
	IF (autorizacoes.COUNT > 0) THEN
      FOR posicao_atual IN autorizacoes.FIRST .. autorizacoes.LAST LOOP
        pkg_condominio.remove_autorizacao(proprietario_in,ano_in,autorizacoes(posicao_atual).contrato);
      END LOOP;
    END IF;

	DELETE FROM administra WHERE (administra.proprietario = proprietario_in) AND (administra.ano = ano_in);
	
    IF (SQL%ROWCOUNT = 0) THEN
      -- Nenhuma linha foi afetada pelo comando DELETE.
      RAISE_APPLICATION_ERROR(-20006, 'Administrador a remover não existe.');
	  
    END IF;

  EXCEPTION
    WHEN OTHERS THEN RAISE;
  END remove_administrador;
	
	
	
	
	PROCEDURE remove_contrato(
	numero_in 			IN contrato.numero%TYPE)
	IS
    CURSOR cursor_autorizacoes IS SELECT autoriza.administrador, autoriza.ano FROM autoriza WHERE (autoriza.contrato = numero_in);
    TYPE tabela_local_autorizacoes IS TABLE OF cursor_autorizacoes%ROWTYPE;
	
	autorizacoes tabela_local_autorizacoes;
  BEGIN
  
	 OPEN cursor_autorizacoes;
    FETCH cursor_autorizacoes BULK COLLECT INTO autorizacoes;
    CLOSE cursor_autorizacoes;
	
	
	IF (autorizacoes.COUNT > 0) THEN
      FOR posicao_atual IN autorizacoes.FIRST .. autorizacoes.LAST LOOP
        pkg_condominio.remove_autorizacao(autorizacoes(posicao_atual).administrador,autorizacoes(posicao_atual).ano,numero_in);
      END LOOP;
    END IF;

	DELETE FROM contrato WHERE (contrato.numero = numero_in);
	
	
    IF (SQL%ROWCOUNT = 0) THEN
      -- Nenhuma linha foi afetada pelo comando DELETE.
      RAISE_APPLICATION_ERROR(-20006, 'Contrato a remover não existe.');

	
    END IF;

  EXCEPTION
    WHEN OTHERS THEN RAISE;
  END remove_contrato;
	
PROCEDURE remove_autorizacao (
    administrador_in    IN autoriza.administrador%TYPE,
	ano_in				IN autoriza.ano%TYPE,
	contrato_in			IN autoriza.contrato%TYPE)
	IS
	BEGIN
	
	DELETE FROM autoriza WHERE (autoriza.administrador = administrador_in) 
	AND (autoriza.ano = ano_in)
	AND (autoriza.contrato = contrato_in) ;
	
    IF (SQL%ROWCOUNT = 0) THEN
      -- Nenhuma linha foi afetada pelo comando DELETE.
      RAISE_APPLICATION_ERROR(-20006, 'Autorização a remover não existe.');
	  
    END IF;

  EXCEPTION
    WHEN OTHERS THEN RAISE;
  END remove_autorizacao;

END pkg_condominio;
/