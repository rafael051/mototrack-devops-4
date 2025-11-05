-- V3: Perfis restritos a USER/ADMIN (PostgreSQL)
-- Objetivo: garantir integridade do domínio de TP_PERFIL.

-- 1) Normaliza ADMINISTRADOR -> ADMIN
UPDATE TB_USUARIO
SET TP_PERFIL = 'ADMIN'
WHERE UPPER(TP_PERFIL) = 'ADMINISTRADOR';

-- 2) Aborta a migração se houver valores inválidos
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM TB_USUARIO
    WHERE UPPER(TP_PERFIL) NOT IN ('USER','ADMIN')
  ) THEN
    RAISE EXCEPTION 'V3 abortada: existem usuários com TP_PERFIL inválido. Ajuste para USER/ADMIN e execute novamente.';
END IF;
END
$$;

-- 3) Remove constraint anterior (se existir) e cria a definitiva
ALTER TABLE TB_USUARIO
DROP CONSTRAINT IF EXISTS CK_USUARIO_TP_PERFIL;

ALTER TABLE TB_USUARIO
    ADD CONSTRAINT CK_USUARIO_TP_PERFIL
        CHECK (TP_PERFIL IN ('USER','ADMIN')) NOT DEFERRABLE INITIALLY IMMEDIATE;
