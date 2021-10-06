

/* Função 1 e gatilho*/

CREATE OR REPLACE FUNCTION limpa_contbank()
RETURNS TRIGGER AS
$$
BEGIN
  UPDATE funcionario SET f_conbank = 0 FROM funcionario WHERE f_situacao = FALSE;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER limpar_contbank
AFTER UPDATE ON funcionario FOR EACH ROW
EXECUTE PROCEDURE limpa_contbank();

/* Função 1*/
CREATE OR REPLACE FUNCTION ultima_consulta()
RETURNS TIME AS
$$
BEGIN
  SELECT p_codigo, r_data, CURRENT_DATE-r_data AS dias_ult_cons FROM registro
  WHERE CURRENT_DATE-r_data >90;
END;
$$
LANGUAGE 'plpgsql';

/* 2 função */
CREATE OR REPLACE FUNCTION count_total(registro.p_codigo%TYPE)
RETURNS NUMERIC AS
$$
DECLARE
  cod_reg alias for $1;
BEGIN
  SELECT COUNT(registro.p_codigo), paciente.p_nome FROM registro, paciente
  WHERE paciente.p_codigo=$1
  GROUP BY paciente.p_codigo;
END;
$$
LANGUAGE 'plpgsql';


/* 3 função*/
CREATE OR REPLACE FUNCTION count_procedimento(procedimento.f_codigo%TYPE)
RETURNS NUMERIC AS
$$
DECLARE
  cod_atendente alias for $1;
BEGIN
  SELECT COUNT(procedimento.seq_proc), funcionario.f_nome, funcionario.f_codigo, atendente.f_codigo FROM funcionario
  INNER JOIN
  procedimento ON atendente.f_codigo=procedimento.f_codigo
  INNER JOIN
  atendente ON funcionario.f_codigo=atendente.f_codigo
  WHERE procedimento.f_codigo=4
  GROUP BY atendente.f_codigo;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER
AFTER
EXECUTE PROCEDURE;



CREATE OR REPLACE FUNCTION
RETURNS
AS
$$
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER
AFTER
EXECUTE PROCEDURE;


CREATE OR REPLACE FUNCTION
RETURNS
AS
$$
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION
RETURNS
AS
$$
$$
LANGUAGE 'plpgsql';
