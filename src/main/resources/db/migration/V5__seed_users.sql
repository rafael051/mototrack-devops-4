-- V5__seed_users.sql
-- Usuários iniciais com senha FIXA (mesmo hash BCRYPT colado no script).
-- Gere o hash UMA vez p/ a senha que você quer (ex.: "Moto@2025!") e cole em <FIXED_BCRYPT>.

-- (Opcional) Garante unicidade case-insensitive por e-mail
CREATE UNIQUE INDEX IF NOT EXISTS ux_tb_usuario_ds_email_lower
    ON tb_usuario (lower(ds_email));

-- Hash BCRYPT fixo da sua senha (COLE o valor aqui em ambos os INSERTs)
-- Exemplo didático (troque!): $2a$12$3oZkQ4kZ8bTzvF7q0mYH4uQvZx7Vx3XzE6dI8rP1lQeZCypx6X3yC
-- Esse é um EXEMPLO — gere o seu e substitua <FIXED_BCRYPT>.
-- Senha em texto: NUNCA deixe no script. Guarde só o hash.

-- ADMIN
INSERT INTO tb_usuario (ds_email, nm_usuario, tp_perfil, ds_senha, id_filial)
VALUES ('admin@moto.local', 'Administrador', 'ADMIN', '$2a$12$S8BfuoAaDCaXjCCsE9jJHuO5V5Ou8aBc7bKIGkESbr7Ii092lcxUi', NULL)
    ON CONFLICT (ds_email) DO UPDATE
                                  SET nm_usuario = EXCLUDED.nm_usuario,
                                  tp_perfil  = EXCLUDED.tp_perfil,
                                  ds_senha   = EXCLUDED.ds_senha,   -- mantém a senha FIXA ao reexecutar
                                  id_filial  = EXCLUDED.id_filial;

-- USER
INSERT INTO tb_usuario (ds_email, nm_usuario, tp_perfil, ds_senha, id_filial)
VALUES ('user@moto.local', 'Usuário Padrão', 'USER', '$2a$12$S8BfuoAaDCaXjCCsE9jJHuO5V5Ou8aBc7bKIGkESbr7Ii092lcxUi', NULL)
    ON CONFLICT (ds_email) DO UPDATE
                                  SET nm_usuario = EXCLUDED.nm_usuario,
                                  tp_perfil  = EXCLUDED.tp_perfil,
                                  ds_senha   = EXCLUDED.ds_senha,   -- mantém a senha FIXA ao reexecutar
                                  id_filial  = EXCLUDED.id_filial;
