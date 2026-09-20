-- ============================================================================
-- 03_consultas.sql
-- Projeto Final — Laboratório de Banco de Dados (GPE17M40083)
-- Tema: Clínica de Fisioterapia — Etapa 1 (N1)
-- 15 consultas de verificação: 5 básicas, 5 junções/agregação, 5 avançadas.
-- Cada bloco traz a pergunta de negócio respondida e, quando aplicável,
-- a regra de negócio (RNxx) verificada.
-- ============================================================================


-- ============================================================================
-- BÁSICAS
-- ============================================================================

-- [B1] Quais são os pacientes cadastrados na clínica, em ordem alfabética?
-- (projeção + ORDER BY)
SELECT nome, data_nascimento
FROM paciente
ORDER BY nome;

-- [B2] Quais pacientes nasceram entre 1980 e 2000 (público-alvo de uma
-- campanha específica de prevenção de lesões)?
-- (WHERE com BETWEEN)
SELECT nome, data_nascimento
FROM paciente
WHERE data_nascimento BETWEEN '1980-01-01' AND '2000-12-31'
ORDER BY data_nascimento;

-- [B3] Quais procedimentos oferecidos pela clínica são classificados como
-- de reabilitação?
-- (WHERE com LIKE)
SELECT nome_procedimento, valor_tabela
FROM procedimento
WHERE nome_procedimento LIKE '%Reabilitação%'
ORDER BY nome_procedimento;

-- [B4] Quais pacientes possuem (ou possuíram) vínculo com os convênios
-- "Vitalis Saúde" ou "Saúde Plena"?
-- (WHERE com IN, join simples)
SELECT DISTINCT p.nome
FROM paciente p
JOIN vinculo_convenio vc ON vc.id_paciente = p.id_paciente
JOIN convenio c ON c.id_convenio = vc.id_convenio
WHERE c.nome_convenio IN ('Vitalis Saúde', 'Saúde Plena')
ORDER BY p.nome;

-- [B5] Quais vínculos de convênio continuam ativos, isto é, ainda não têm
-- data de encerramento registrada?
-- (tratamento de NULL)
SELECT p.nome AS paciente, c.nome_convenio, vc.data_inicio
FROM vinculo_convenio vc
JOIN paciente p ON p.id_paciente = vc.id_paciente
JOIN convenio c ON c.id_convenio = vc.id_convenio
WHERE vc.data_fim IS NULL
ORDER BY vc.data_inicio;


-- ============================================================================
-- JUNÇÕES E AGREGAÇÃO
-- ============================================================================

-- [J1] Qual a agenda completa (paciente, fisioterapeuta, sala) dos
-- atendimentos realizados em um dia específico da clínica?
-- (junção com quatro tabelas)
SELECT a.data_hora_inicio, pac.nome AS paciente, prof.nome AS fisioterapeuta,
       s.numero_sala
FROM agendamento a
JOIN paciente pac        ON pac.id_paciente = a.id_paciente
JOIN profissional prof   ON prof.id_profissional = a.id_fisioterapeuta
JOIN sala s              ON s.id_sala = a.id_sala
WHERE DATE(a.data_hora_inicio) = '2026-06-15'
ORDER BY a.data_hora_inicio;

-- [J2] Quais pacientes possuem convênio ativo e quais são atendidos como
-- particulares (sem nenhum convênio vinculado)?
-- (LEFT JOIN — preserva pacientes sem convênio)
SELECT p.nome AS paciente, c.nome_convenio
FROM paciente p
LEFT JOIN vinculo_convenio vc ON vc.id_paciente = p.id_paciente AND vc.data_fim IS NULL
LEFT JOIN convenio c          ON c.id_convenio = vc.id_convenio
ORDER BY p.nome;

-- [J3] Quais fisioterapeutas realizaram mais de 10 atendimentos no período
-- carregado?
-- (GROUP BY + HAVING)
SELECT prof.nome AS fisioterapeuta, COUNT(*) AS total_atendimentos
FROM agendamento a
JOIN profissional prof ON prof.id_profissional = a.id_fisioterapeuta
WHERE a.status = 'realizado'
GROUP BY prof.nome
HAVING COUNT(*) > 10
ORDER BY total_atendimentos DESC;

-- [J4] Qual o faturamento total gerado por cada procedimento oferecido
-- pela clínica?
-- (junção + agregação SUM)
SELECT proc.nome_procedimento, SUM(ia.valor_cobrado) AS faturamento_total,
       COUNT(*) AS quantidade_realizada
FROM item_agendamento ia
JOIN procedimento proc ON proc.id_procedimento = ia.id_procedimento
JOIN agendamento a      ON a.id_agendamento = ia.id_agendamento
WHERE a.status = 'realizado'
GROUP BY proc.nome_procedimento
ORDER BY faturamento_total DESC;

-- [J5] Qual a taxa de ocupação (número de atendimentos realizados) de
-- cada sala da clínica?
-- (junção + agregação COUNT)
SELECT s.numero_sala, COUNT(a.id_agendamento) AS atendimentos_realizados
FROM sala s
LEFT JOIN agendamento a ON a.id_sala = s.id_sala AND a.status = 'realizado'
GROUP BY s.numero_sala
ORDER BY atendimentos_realizados DESC;


-- ============================================================================
-- AVANÇADAS
-- ============================================================================

-- [A1] Quais agendamentos tiveram valor total cobrado acima da média dos
-- atendimentos do mesmo fisioterapeuta (possíveis atendimentos de maior
-- complexidade ou com procedimentos adicionais)?
-- (subconsulta correlacionada)
SELECT a.id_agendamento, prof.nome AS fisioterapeuta,
       (SELECT SUM(ia.valor_cobrado) FROM item_agendamento ia
        WHERE ia.id_agendamento = a.id_agendamento) AS valor_total
FROM agendamento a
JOIN profissional prof ON prof.id_profissional = a.id_fisioterapeuta
WHERE (SELECT SUM(ia.valor_cobrado) FROM item_agendamento ia
       WHERE ia.id_agendamento = a.id_agendamento)
      > (SELECT AVG(sub_total.total_item)
         FROM (SELECT ia2.id_agendamento, SUM(ia2.valor_cobrado) AS total_item
               FROM item_agendamento ia2
               JOIN agendamento a2 ON a2.id_agendamento = ia2.id_agendamento
               WHERE a2.id_fisioterapeuta = a.id_fisioterapeuta
               GROUP BY ia2.id_agendamento) sub_total)
ORDER BY valor_total DESC;

-- [A2] Quais convênios oferecem cobertura de 100% para pelo menos um
-- procedimento da clínica?
-- (EXISTS)
SELECT c.nome_convenio
FROM convenio c
WHERE EXISTS (
    SELECT 1 FROM cobertura cob
    WHERE cob.id_convenio = c.id_convenio
      AND cob.percentual_cobertura = 100
)
ORDER BY c.nome_convenio;

-- [A3] Há algum profissional cadastrado que não pertence a nenhuma das
-- subclasses previstas (Fisioterapeuta, Recepcionista ou Administrativo)?
-- Verificação da RN05 (especialização total e exclusiva).
-- (NOT EXISTS combinado — resultado esperado: 0 linhas)
SELECT prof.id_profissional, prof.nome
FROM profissional prof
WHERE NOT EXISTS (SELECT 1 FROM fisioterapeuta f WHERE f.id_profissional = prof.id_profissional)
  AND NOT EXISTS (SELECT 1 FROM recepcionista r WHERE r.id_profissional = prof.id_profissional)
  AND NOT EXISTS (SELECT 1 FROM administrativo ad WHERE ad.id_profissional = prof.id_profissional);

-- [A4] Existe algum atendimento realizado por um fisioterapeuta sem
-- qualificação registrada na especialidade exigida pelo procedimento
-- executado? Verificação da RN09.
-- (NOT EXISTS — resultado esperado: 0 linhas)
SELECT a.id_agendamento, ia.id_procedimento
FROM item_agendamento ia
JOIN agendamento a  ON a.id_agendamento = ia.id_agendamento
JOIN procedimento p ON p.id_procedimento = ia.id_procedimento
WHERE NOT EXISTS (
    SELECT 1 FROM qualificacao q
    WHERE q.id_profissional = a.id_fisioterapeuta
      AND q.id_especialidade = p.id_especialidade_exigida
);

-- [A5] Há sobreposição de horário entre agendamentos do mesmo
-- fisioterapeuta ou da mesma sala (pergunta de negócio não trivial:
-- a agenda da clínica está livre de conflitos de horário)?
-- Verificação das RN10 e RN11 — auto-junção da tabela AGENDAMENTO.
-- (resultado esperado: 0 linhas em ambos os casos)
SELECT 'conflito_fisioterapeuta' AS tipo, a1.id_agendamento AS agendamento_1,
       a2.id_agendamento AS agendamento_2
FROM agendamento a1
JOIN agendamento a2
  ON a1.id_fisioterapeuta = a2.id_fisioterapeuta
 AND a1.id_agendamento < a2.id_agendamento
WHERE a1.data_hora_inicio < a2.data_hora_fim
  AND a2.data_hora_inicio < a1.data_hora_fim
UNION ALL
SELECT 'conflito_sala', a1.id_agendamento, a2.id_agendamento
FROM agendamento a1
JOIN agendamento a2
  ON a1.id_sala = a2.id_sala
 AND a1.id_agendamento < a2.id_agendamento
WHERE a1.data_hora_inicio < a2.data_hora_fim
  AND a2.data_hora_inicio < a1.data_hora_fim;
