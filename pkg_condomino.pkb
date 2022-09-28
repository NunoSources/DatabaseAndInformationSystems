CREATE SEQUENCE seq_auditoria_ordem
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
  END atualiza;
  
 PROCEDURE regista_contrato (
    empresa_in 			IN contrato.empresa%TYPE,
	equipamento_in		IN contrato.equipamento%TYPE,
	ano_in				IN contrato.ano%TYPE,
	euros_in			IN contrato.euros%TYPE)
  IS
  eqpm_count number;
 BEGIN
   
	SELECT count(*) into eqpm_count 
	FROM contrato 
	WHERE (contrato.ano = ano_in)
	AND (contrato.equipamento = equipamento_in);
	   IF (adm_count < 1) THEN
			
			INSERT INTO contrato(empresa,ano)
				VALUES (proprietario_in,ano_in);
		ELSE 
			RAISE_APPLICATION_ERROR(-20003, 'Não pode haver dois contratos no mesmo ano para o mesmo tipo de equipamento ');
		END IF;
	
	EXCEPTION
     WHEN OTHERS THEN
      BEGIN
        IF (SQLCODE = -2291) THEN
          RAISE_APPLICATION_ERROR(-20002, 'Proprietario tem de existir');
        END IF;
        RAISE;
      END;
  END atualiza;
	
	
;

	

  -- --------------------------------------------------------------------------
  -- Atualiza o vencimento de um funcionário.
  PROCEDURE atualiza (
    numero_in     IN funcionario.numero%TYPE,
    vencimento_in IN funcionario.vencimento%TYPE)
  IS
    vencimento_atual funcionario.vencimento%TYPE;

  BEGIN
    -- Obtenção do vencimento atual.
    SELECT vencimento INTO vencimento_atual
      FROM funcionario
     WHERE (numero = numero_in)
       FOR UPDATE OF vencimento;

    IF (vencimento_in <= vencimento_atual) THEN
      RAISE_APPLICATION_ERROR(-20003, 'Novo vencimento tem de ' ||
                                      'ser superior ao atual.');
    ELSE
      -- Vencimento pode ser atualizado.
      UPDATE funcionario
         SET vencimento = vencimento_in
       WHERE (numero = numero_in);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN RAISE;
  END atualiza;

  -- --------------------------------------------------------------------------
  -- Remove um funcionário já existente.
  PROCEDURE remove (
    numero_in IN funcionario.numero%TYPE)
  IS
  BEGIN
    DELETE FROM funcionario WHERE (numero = numero_in);

    IF (SQL%ROWCOUNT = 0) THEN
      -- Nenhuma linha foi afetada pelo comando DELETE.
      RAISE_APPLICATION_ERROR(-20004, 'Funcionário a remover não existe.');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN RAISE;
  END remove;

  -- --------------------------------------------------------------------------
  -- Remove todos os funcionários, um de cada vez.
  PROCEDURE remove_todos
  IS
    -- Cursor para obter os números dos funcionários e tipo de tabela local
    -- capaz de armazenar as linhas devolvidas pelo cursor.
    CURSOR cursor_funcionarios IS SELECT numero FROM funcionario;
    TYPE tabela_local_funcionarios IS TABLE OF cursor_funcionarios%ROWTYPE;

    funcionarios tabela_local_funcionarios;

  BEGIN
    -- Carrega todos os números de funcionário para uma tabela local.
    OPEN cursor_funcionarios;
    FETCH cursor_funcionarios BULK COLLECT INTO funcionarios;
    CLOSE cursor_funcionarios;

    -- Invoca a remoção de cada um dos funcionários, sendo da responsabilidade
    -- da operação pkg_funcionario.remove saber como remover um funcionário.
    IF (funcionarios.COUNT > 0) THEN
      FOR posicao_atual IN funcionarios.FIRST .. funcionarios.LAST LOOP
        pkg_funcionario.remove(funcionarios(posicao_atual).numero);
      END LOOP;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        -- Libertação de recursos (se aplicável).
        IF (cursor_funcionarios%ISOPEN) THEN
          CLOSE cursor_funcionarios;
        END IF;

        RAISE;
      END;
  END remove_todos;

  -- --------------------------------------------------------------------------
  -- Soma um dado número de melhores vencimentos de funcionários.
  FUNCTION soma_melhores_vencimentos (
    quantos_in IN NUMBER)
    RETURN NUMBER
  IS
    -- Cursor para obter os vencimentos dos funcionários, ordenados.
    CURSOR cursor_vencimentos IS
      SELECT vencimento
        FROM funcionario
       ORDER BY vencimento DESC;

    -- Guarda um vencimento de funcionário de cada vez.
    vencimento_atual funcionario.vencimento%TYPE;

    -- Soma dos melhores vencimentos.
    soma_vencimentos NUMBER := 0;

  BEGIN
    -- Abertura do cursor.
    OPEN cursor_vencimentos;

    -- Obtenção das primeiras linhas do resultado, correspondentes aos melhores
    -- vencimentos. Não vai ser necessário ler todas as linhas do resultado.
    FOR contador IN 1 .. quantos_in LOOP

      -- Leitura do vencimento.
      FETCH cursor_vencimentos INTO vencimento_atual;

      IF (cursor_vencimentos%FOUND) THEN
        soma_vencimentos := soma_vencimentos + vencimento_atual;
      ELSE
        -- Não há mais linhas para ler.
        EXIT;
      END IF;
    END LOOP;

    -- Libertação de recursos.
    CLOSE cursor_vencimentos;

    RETURN soma_vencimentos;

  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        -- Libertação de recursos (se aplicável).
        IF (cursor_vencimentos%ISOPEN) THEN
          CLOSE cursor_vencimentos;
        END IF;
      END;
  END soma_melhores_vencimentos;

  -- --------------------------------------------------------------------------
  -- Lista um dado número de funcionários com os melhores vencimentos.
  FUNCTION lista_melhores_vencimentos (
    quantos_in IN NUMBER)
    RETURN SYS_REFCURSOR
  IS
    -- Cursor para obter os dados de todos os funcionários.
    cursor_funcionarios SYS_REFCURSOR;

  BEGIN
    OPEN cursor_funcionarios FOR
      SELECT *
        FROM (SELECT *
                FROM funcionario
               ORDER BY vencimento DESC)
       WHERE (ROWNUM <= quantos_in);

    -- Linhas do resultado da interrogação são lidas por quem invoca a função.
    RETURN cursor_funcionarios;

  EXCEPTION
    WHEN OTHERS THEN RAISE;
  END lista_melhores_vencimentos;

  -- --------------------------------------------------------------------------
  -- Devolve 'elevado' se um vencimento for superior ou igual a um dado valor
  -- de referência, ou 'reduzido' no caso contrário.
  FUNCTION qualifica_vencimento (
    vencimento_in IN funcionario.vencimento%TYPE,
    referencia_in IN funcionario.vencimento%TYPE)
    RETURN VARCHAR2
  IS
    -- Qualificação de vencimento por omissão.
    qualificacao VARCHAR2(8) := 'reduzido';

  BEGIN
    IF (vencimento_in >= referencia_in) THEN
      qualificacao := 'elevado';
    END IF;

    RETURN qualificacao;

  END qualifica_vencimento;

END pkg_funcionario;
/