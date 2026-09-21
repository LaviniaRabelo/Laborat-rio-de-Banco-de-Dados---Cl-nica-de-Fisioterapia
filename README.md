# Clínica de Fisioterapia — Banco de Dados

Projeto Final da disciplina **Laboratório de Banco de Dados** (GPE17M40053) 
Bacharelado em Engenharia de Software, Universidade Católica de Brasília (UCB).

**Professor:** Samuel Novais Moura Júnior 
**Semestre:** 2026/2

## Equipe

| Papel | Nome |
|---|---|
| Analista de domínio | Francisco Italo|
| Modelador de dados | Lavinia Paiva |
| Modelador de dados (apoio) | João Paulo Piau |
| Administrador do banco | Isabela Dourado|
| Desenvolvedor | Gabriel Matta / Lavinia Paiva |

## Sobre o projeto

O sistema modela o funcionamento de uma clínica de fisioterapia com atendimento particular e conveniado, nas especialidades ortopédica, neurológica, respiratória e desportiva. Cobre o cadastro de pacientes e profissionais, o agendamento e execução de sessões, o controle de convênios e cobertura de procedimentos, e o registro da evolução clínica do paciente ao longo do tratamento, conforme exigido pela Resolução COFFITO nº 414/2012.

A descrição completa do domínio, as 20 regras de negócio, o modelo entidade-relacionamento, o dicionário de dados, o modelo lógico e a análise de normalização estão no relatório da Etapa 1 (`docs/relatorio-etapa1.pdf`).

## Estrutura do repositório

    repositorio/
    ├── README.md                    este arquivo
    ├── docs/
    │   ├── relatorio-etapa1.pdf    relatório consolidado (A1–A5)
    │   ├── mer-conceitual.pdf      diagrama ER exportado
    │   ├── mer-conceitual.drawio   arquivo-fonte do diagrama (brModelo/draw.io)
    │   ├── modelo-logico.pdf
    │   └── dicionario-dados.pdf
    └── sql/
        ├── 01_ddl.sql              cria o banco e as 17 tabelas
        ├── 02_carga.sql            dados fictícios (50 pacientes, 120 agendamentos...)
        └── 03_consultas.sql        15 consultas de verificação comentadas

## Requisitos técnicos

- **SGBD:** PostgreSQL 14 ou superior
- Cliente `psql` (ou qualquer cliente SQL compatível: DBeaver, pgAdmin etc.)

## Como reconstruir o banco do zero

### 1. Criar o banco

    createdb clinica_fisioterapia

### 2. Rodar os scripts, na ordem, dentro da pasta sql/

    psql -d clinica_fisioterapia -f sql/01_ddl.sql
    psql -d clinica_fisioterapia -f sql/02_carga.sql
    psql -d clinica_fisioterapia -f sql/03_consultas.sql

Os três scripts foram testados em sequência, em base limpa, sem apresentar erros.

O `01_ddl.sql` pode ser executado quantas vezes forem necessárias.

## Resumo do modelo

- **17 tabelas:** 11 entidades do MER + 4 entidades associativas (N:N com atributo próprio) + 2 tabelas de atributo multivalorado
- **1 autorrelacionamento:** indicação de paciente por paciente
- **1 especialização:** total e exclusiva (Profissional → Fisioterapeuta / Recepcionista / Administrativo)
- **1 entidade fraca:** Evolução, dependente de Paciente
- **20 regras de negócio:** rastreadas do documento de escopo até a implementação (ver `docs/relatorio-etapa1.pdf`, seção 1.2)

## Uso de inteligência artificial

O uso de assistente de IA está declarado no relatório (seção "Declaração de uso de inteligência artificial"), conforme exigido no item 9 do enunciado.

Todo o SQL gerado foi executado e verificado pela equipe antes da entrega.
