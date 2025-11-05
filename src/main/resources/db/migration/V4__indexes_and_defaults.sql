-- =========================
-- Índices em chaves-estrangeiras
-- =========================
CREATE INDEX IF NOT EXISTS idx_moto_filial         ON tb_moto (id_filial);
CREATE INDEX IF NOT EXISTS idx_evento_moto         ON tb_evento (id_moto);
CREATE INDEX IF NOT EXISTS idx_agendamento_moto    ON tb_agendamento (id_moto);
CREATE INDEX IF NOT EXISTS idx_usuario_filial      ON tb_usuario (id_filial);

-- =========================
-- Índices de busca comuns
-- =========================
CREATE INDEX IF NOT EXISTS idx_usuario_nome           ON tb_usuario (nm_usuario);
CREATE INDEX IF NOT EXISTS idx_usuario_email_lower    ON tb_usuario ((LOWER(ds_email)));

-- =========================
-- Índices úteis por uso (alinhados ao model)
-- =========================
-- Eventos por moto + data/hora
CREATE INDEX IF NOT EXISTS idx_evento_moto_data       ON tb_evento (id_moto, dt_hr_evento DESC);

-- Eventos por tipo
CREATE INDEX IF NOT EXISTS idx_evento_tipo            ON tb_evento (tp_evento);

-- Agendamentos por data
CREATE INDEX IF NOT EXISTS idx_agendamento_data       ON tb_agendamento (dt_agendada);

-- Agendamentos por moto + data
CREATE INDEX IF NOT EXISTS idx_agendamento_moto_data  ON tb_agendamento (id_moto, dt_agendada DESC);

-- (Opcional, idempotência lógica no banco para “1 evento por dia/tipo/motivo/moto”)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = current_schema() AND indexname = 'uq_evento_moto_tipo_motivo_dia'
  ) THEN
    EXECUTE '
      CREATE UNIQUE INDEX uq_evento_moto_tipo_motivo_dia
      ON tb_evento (id_moto, tp_evento, ds_motivo, (dt_hr_evento::date))
    ';
END IF;
END
$$ LANGUAGE plpgsql;

-- =========================
-- Defaults de criação
-- =========================
-- Motor/Agendamento: mantém como você já fez
DO $$
BEGIN
  -- tb_moto.dt_criacao
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = current_schema()
      AND table_name = 'tb_moto'
      AND column_name = 'dt_criacao'
      AND column_default IS NULL
  ) THEN
    EXECUTE 'ALTER TABLE tb_moto ALTER COLUMN dt_criacao SET DEFAULT CURRENT_TIMESTAMP';
END IF;

  -- tb_agendamento.dt_criacao
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = current_schema()
      AND table_name = 'tb_agendamento'
      AND column_name = 'dt_criacao'
      AND column_default IS NULL
  ) THEN
    EXECUTE 'ALTER TABLE tb_agendamento ALTER COLUMN dt_criacao SET DEFAULT CURRENT_TIMESTAMP';
END IF;

  -- Evento: teu MODEL usa @CreationTimestamp em dt_hr_evento (nullable=false).
  -- Opcional, mas recomendado deixar DEFAULT no banco para scripts SQL diretos:
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = current_schema()
      AND table_name = 'tb_evento'
      AND column_name = 'dt_hr_evento'
      AND column_default IS NULL
  ) THEN
    EXECUTE 'ALTER TABLE tb_evento ALTER COLUMN dt_hr_evento SET DEFAULT CURRENT_TIMESTAMP';
END IF;
END
$$ LANGUAGE plpgsql;
