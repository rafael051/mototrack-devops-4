-- V2: Inserção de dados mínimos de referência (PostgreSQL)
-- Objetivo: disponibilizar registros básicos para testes de navegação.

-- =========================================
-- Filiais (idempotente por nome da filial)
-- =========================================
INSERT INTO TB_FILIAL (NM_FILIAL, DS_ENDERECO, DS_BAIRRO, NR_CEP, DS_CIDADE, DS_ESTADO, VL_LATITUDE, VL_LONGITUDE, RAIO_GEOFENCE_M)
SELECT 'Matriz São Paulo', 'Av. Paulista, 1000', 'Bela Vista', '01310-000', 'São Paulo', 'SP', -23.5617, -46.6559, 500
    WHERE NOT EXISTS (SELECT 1 FROM TB_FILIAL WHERE NM_FILIAL = 'Matriz São Paulo');

INSERT INTO TB_FILIAL (NM_FILIAL, DS_ENDERECO, DS_BAIRRO, NR_CEP, DS_CIDADE, DS_ESTADO, VL_LATITUDE, VL_LONGITUDE, RAIO_GEOFENCE_M)
SELECT 'Filial Rio', 'Rua das Laranjeiras, 200', 'Laranjeiras', '22240-003', 'Rio de Janeiro', 'RJ', -22.9410, -43.1872, 400
    WHERE NOT EXISTS (SELECT 1 FROM TB_FILIAL WHERE NM_FILIAL = 'Filial Rio');

-- Novas filiais
INSERT INTO TB_FILIAL (NM_FILIAL, DS_ENDERECO, DS_BAIRRO, NR_CEP, DS_CIDADE, DS_ESTADO, VL_LATITUDE, VL_LONGITUDE, RAIO_GEOFENCE_M)
SELECT 'Filial BH', 'Av. do Contorno, 4000', 'Funcionários', '30110-021', 'Belo Horizonte', 'MG', -19.9333, -43.9257, 350
    WHERE NOT EXISTS (SELECT 1 FROM TB_FILIAL WHERE NM_FILIAL = 'Filial BH');

INSERT INTO TB_FILIAL (NM_FILIAL, DS_ENDERECO, DS_BAIRRO, NR_CEP, DS_CIDADE, DS_ESTADO, VL_LATITUDE, VL_LONGITUDE, RAIO_GEOFENCE_M)
SELECT 'Filial Curitiba', 'Av. Sete de Setembro, 3000', 'Centro', '80230-010', 'Curitiba', 'PR', -25.4411, -49.2769, 300
    WHERE NOT EXISTS (SELECT 1 FROM TB_FILIAL WHERE NM_FILIAL = 'Filial Curitiba');

-- =====================================================
-- Motos (idempotente via UNIQUE em CD_PLACA - já existe)
-- =====================================================
INSERT INTO TB_MOTO (NR_ANO, DT_CRIACAO, DS_MARCA, DS_MODELO, CD_PLACA, DS_STATUS, VL_LATITUDE, VL_LONGITUDE, ID_FILIAL)
VALUES (
           2021, CURRENT_TIMESTAMP, 'Honda', 'CG 160', 'ABC1D23', 'ATIVA', -23.5618, -46.6562,
           (SELECT ID_FILIAL FROM TB_FILIAL WHERE NM_FILIAL = 'Matriz São Paulo')
       )
    ON CONFLICT (CD_PLACA) DO NOTHING;

INSERT INTO TB_MOTO (NR_ANO, DT_CRIACAO, DS_MARCA, DS_MODELO, CD_PLACA, DS_STATUS, VL_LATITUDE, VL_LONGITUDE, ID_FILIAL)
VALUES (
           2022, CURRENT_TIMESTAMP, 'Yamaha', 'Factor 150', 'EFG4H56', 'ATIVA', -22.9412, -43.1870,
           (SELECT ID_FILIAL FROM TB_FILIAL WHERE NM_FILIAL = 'Filial Rio')
       )
    ON CONFLICT (CD_PLACA) DO NOTHING;

-- Novas motos
INSERT INTO TB_MOTO (NR_ANO, DT_CRIACAO, DS_MARCA, DS_MODELO, CD_PLACA, DS_STATUS, VL_LATITUDE, VL_LONGITUDE, ID_FILIAL)
VALUES (
           2020, CURRENT_TIMESTAMP, 'Honda', 'Biz 125', 'IJK7L89', 'ATIVA', -19.9329, -43.9378,
           (SELECT ID_FILIAL FROM TB_FILIAL WHERE NM_FILIAL = 'Filial BH')
       )
    ON CONFLICT (CD_PLACA) DO NOTHING;

INSERT INTO TB_MOTO (NR_ANO, DT_CRIACAO, DS_MARCA, DS_MODELO, CD_PLACA, DS_STATUS, VL_LATITUDE, VL_LONGITUDE, ID_FILIAL)
VALUES (
           2023, CURRENT_TIMESTAMP, 'Yamaha', 'Fazer 250', 'MNO2P34', 'MANUTENCAO', -25.4405, -49.2730,
           (SELECT ID_FILIAL FROM TB_FILIAL WHERE NM_FILIAL = 'Filial Curitiba')
       )
    ON CONFLICT (CD_PLACA) DO NOTHING;

INSERT INTO TB_MOTO (NR_ANO, DT_CRIACAO, DS_MARCA, DS_MODELO, CD_PLACA, DS_STATUS, VL_LATITUDE, VL_LONGITUDE, ID_FILIAL)
VALUES (
           2019, CURRENT_TIMESTAMP, 'Honda', 'XRE 190', 'QRS5T67', 'ATIVA', -23.5650, -46.6540,
           (SELECT ID_FILIAL FROM TB_FILIAL WHERE NM_FILIAL = 'Matriz São Paulo')
       )
    ON CONFLICT (CD_PLACA) DO NOTHING;

-- ==========================================================
-- Agendamentos (idempotente por moto + descrição + data)
-- ==========================================================
-- 1) agenda para a moto ABC1D23, amanhã
INSERT INTO TB_AGENDAMENTO (DT_AGENDADA, DT_CRIACAO, DS_DESCRICAO, ID_MOTO)
SELECT
            CURRENT_TIMESTAMP + INTERVAL '1 day',
    CURRENT_TIMESTAMP,
    'Manutenção preventiva',
    m.ID_MOTO
FROM TB_MOTO m
WHERE m.CD_PLACA = 'ABC1D23'
  AND NOT EXISTS (
    SELECT 1
    FROM TB_AGENDAMENTO a
    WHERE a.ID_MOTO = m.ID_MOTO
  AND a.DS_DESCRICAO = 'Manutenção preventiva'
  AND a.DT_AGENDADA::date = (CURRENT_DATE + INTERVAL '1 day')::date
    );

-- 2) agenda para a moto EFG4H56, em 2 dias
INSERT INTO TB_AGENDAMENTO (DT_AGENDADA, DT_CRIACAO, DS_DESCRICAO, ID_MOTO)
SELECT
            CURRENT_TIMESTAMP + INTERVAL '2 day',
    CURRENT_TIMESTAMP,
    'Revisão 10.000 km',
    m.ID_MOTO
FROM TB_MOTO m
WHERE m.CD_PLACA = 'EFG4H56'
  AND NOT EXISTS (
    SELECT 1
    FROM TB_AGENDAMENTO a
    WHERE a.ID_MOTO = m.ID_MOTO
  AND a.DS_DESCRICAO = 'Revisão 10.000 km'
  AND a.DT_AGENDADA::date = (CURRENT_DATE + INTERVAL '2 day')::date
    );

-- 3) agenda para a moto IJK7L89, hoje + 6 horas
INSERT INTO TB_AGENDAMENTO (DT_AGENDADA, DT_CRIACAO, DS_DESCRICAO, ID_MOTO)
SELECT
            CURRENT_TIMESTAMP + INTERVAL '6 hour',
    CURRENT_TIMESTAMP,
    'Troca de pastilha de freio',
    m.ID_MOTO
FROM TB_MOTO m
WHERE m.CD_PLACA = 'IJK7L89'
  AND NOT EXISTS (
    SELECT 1
    FROM TB_AGENDAMENTO a
    WHERE a.ID_MOTO = m.ID_MOTO
  AND a.DS_DESCRICAO = 'Troca de pastilha de freio'
  AND a.DT_AGENDADA::date = CURRENT_DATE
    );

-- ==========================================
-- Eventos (idempotente por moto + tipo + data)
-- Compatível com o model: tp_evento, ds_motivo, dt_hr_evento, ds_localizacao
-- ==========================================

-- Evento: deslocamento recente (ABC1D23)
INSERT INTO tb_evento (dt_hr_evento, tp_evento, ds_motivo, ds_localizacao, id_moto)
SELECT
            CURRENT_TIMESTAMP - INTERVAL '3 hour',
    'DESLOCAMENTO',
    'Saída para entrega',
    'Av. Paulista, 1500 - SP',
    m.id_moto
FROM tb_moto m
WHERE m.cd_placa = 'ABC1D23'
  AND NOT EXISTS (
    SELECT 1 FROM tb_evento e
    WHERE e.id_moto = m.id_moto
  AND e.tp_evento = 'DESLOCAMENTO'
  AND e.dt_hr_evento::date = CURRENT_DATE
    );

-- Evento: parada técnica (ABC1D23)
INSERT INTO tb_evento (dt_hr_evento, tp_evento, ds_motivo, ds_localizacao, id_moto)
SELECT
            CURRENT_TIMESTAMP - INTERVAL '2 hour',
    'PARADA',
    'Parada breve para ajuste de corrente',
    'R. Augusta, 900 - SP',
    m.id_moto
FROM tb_moto m
WHERE m.cd_placa = 'ABC1D23'
  AND NOT EXISTS (
    SELECT 1 FROM tb_evento e
    WHERE e.id_moto = m.id_moto
  AND e.tp_evento = 'PARADA'
  AND e.ds_motivo = 'Parada breve para ajuste de corrente'
  AND e.dt_hr_evento::date = CURRENT_DATE
    );

-- Evento: ocorrência (EFG4H56) - pneu furado (ontem)
INSERT INTO tb_evento (dt_hr_evento, tp_evento, ds_motivo, ds_localizacao, id_moto)
SELECT
            CURRENT_TIMESTAMP - INTERVAL '1 day',
    'OCORRENCIA',
    'Pneu furado',
    'Laranjeiras - Rio de Janeiro - RJ',
    m.id_moto
FROM tb_moto m
WHERE m.cd_placa = 'EFG4H56'
  AND NOT EXISTS (
    SELECT 1 FROM tb_evento e
    WHERE e.id_moto = m.id_moto
  AND e.tp_evento = 'OCORRENCIA'
  AND e.ds_motivo = 'Pneu furado'
  AND e.dt_hr_evento::date = (CURRENT_DATE - INTERVAL '1 day')::date
    );

-- Evento: manutenção corretiva (MNO2P34) - há 7 dias
INSERT INTO tb_evento (dt_hr_evento, tp_evento, ds_motivo, ds_localizacao, id_moto)
SELECT
            CURRENT_TIMESTAMP - INTERVAL '7 day',
    'MANUTENCAO',
    'Troca de relação',
    'Av. Sete de Setembro - Curitiba - PR',
    m.id_moto
FROM tb_moto m
WHERE m.cd_placa = 'MNO2P34'
  AND NOT EXISTS (
    SELECT 1 FROM tb_evento e
    WHERE e.id_moto = m.id_moto
  AND e.tp_evento = 'MANUTENCAO'
  AND e.ds_motivo = 'Troca de relação'
  AND e.dt_hr_evento::date = (CURRENT_DATE - INTERVAL '7 day')::date
    );

-- Evento: (QRS5T67) saída de perímetro - hoje (30 min atrás)
INSERT INTO tb_evento (dt_hr_evento, tp_evento, ds_motivo, ds_localizacao, id_moto)
SELECT
            CURRENT_TIMESTAMP - INTERVAL '30 minute',
    'GEOFENCE',
    'Saída do perímetro da Matriz',
    'Av. Paulista, 2000 - SP',
    m.id_moto
FROM tb_moto m
WHERE m.cd_placa = 'QRS5T67'
  AND NOT EXISTS (
    SELECT 1 FROM tb_evento e
    WHERE e.id_moto = m.id_moto
  AND e.tp_evento = 'GEOFENCE'
  AND e.ds_motivo = 'Saída do perímetro da Matriz'
  AND e.dt_hr_evento::date = CURRENT_DATE
    );
