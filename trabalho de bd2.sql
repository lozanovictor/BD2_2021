

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
  SELECT COUNT(procedimento.seq_proc), funcionario.f_nome, funcionario.f_codigo FROM funcionario
  INNER JOIN
  procedimento ON funcionario.f_codigo=procedimento.f_codigo
  WHERE procedimento.f_codigo=cod_atendente
  GROUP BY funcionario.f_codigo;
END;
$$
LANGUAGE 'plpgsql';



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

/* 2 função com gatilho*/
CREATE OR REPLACE FUNCTION turno_func()
RETURNS TRIGGER AS
$$
DECLARE
  manha NUMERIC;
  tarde NUMERIC;
  noite NUMERIC;
  cod NUMERIC;
BEGIN
  cod := TG_NARGS;
  SELECT COUNT(*) INTO manha FROM atendente WHERE turno='mat';
  SELECT COUNT(*) INTO tarde FROM atendente WHERE turno='vesp';
  SELECT COUNT(*) INTO noite FROM atendente WHERE turno='not';
  
  IF manha < tarde AND manha < noite
  THEN
      INSERT INTO atendente (turno, f_codigo) VALUES('mat', cod);
  ELSE
      IF tarde < manha AND tarde < noite
      THEN
          INSERT INTO atendente (turno, f_codigo) VALUES('vesp', cod);
      ELSE
      INSERT INTO atendente (turno, f_codigo) VALUES('not', cod);
      END IF;
  END IF;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER turnos
AFTER UPDATE ON funcionario FOR EACH ROW
EXECUTE PROCEDURE turno_func();

/* 3 função com gatilho*/
CREATE OR REPLACE FUNCTION apa_disp()
RETURNS TRIGGER AS
$$
DECLARE
    status BOOLEAN;
    procedimento NUMERIC;
BEGIN 
  procedimento :=TG_NARGS;
  SELECT ap_status as STATUS FROM aparelho 
  WHERE ap_codigo IN (SELECT ap_codigo FROM ap_proc WHERE seq_proc = procedimento);
  IF status = true
  THEN
    RAISE NOTICE 'Aparelho disponivel';
   ELSE
    RAISE NOTICE 'Aparelho indisponivel';
   END IF;
END;  
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER disponivel_apa
AFTER UPDATE ON procedimento FOR EACH ROW
EXECUTE PROCEDURE apa_disp();
