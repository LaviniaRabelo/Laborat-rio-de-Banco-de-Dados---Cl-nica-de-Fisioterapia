DROP DATABASE IF EXISTS clinica_fisioterapia;
CREATE DATABASE clinica_fisioterapia
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_general_ci;

USE clinica_fisioterapia;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS
    evolucao, item_agendamento, agendamento, cobertura, procedimento,
    equipamento_sala, sala, vinculo_convenio, convenio, qualificacao,
    especialidade, administrativo, recepcionista, fisioterapeuta,
    profissional, telefone_paciente, paciente;
SET FOREIGN_KEY_CHECKS = 1;

-- PACIENTE

CREATE TABLE paciente (
    id_paciente INT NOT NULL AUTO_INCREMENT,
    cpf CHAR(11) NOT NULL,              
    nome VARCHAR(120) NOT NULL,
    data_nascimento DATE NOT NULL,               
    logradouro VARCHAR(120),
    numero_endereco VARCHAR(10),
    bairro VARCHAR(60),
    cidade VARCHAR(60),
    uf CHAR(2),
    cep CHAR(8),
    id_paciente_indicador INT,                               
    CONSTRAINT pk_paciente PRIMARY KEY (id_paciente),
    CONSTRAINT uq_paciente_cpf UNIQUE (cpf),
    CONSTRAINT ck_paciente_cpf_formato CHECK (cpf REGEXP '^[0-9]{11}$'),
    CONSTRAINT ck_paciente_uf CHECK (uf IS NULL OR uf REGEXP '^[A-Z]{2}$'),
    CONSTRAINT fk_paciente_indicador FOREIGN KEY (id_paciente_indicador)
        REFERENCES paciente (id_paciente)
        ON DELETE SET NULL ON UPDATE CASCADE                    
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE INDEX idx_paciente_indicador ON paciente (id_paciente_indicador);

-- TELEFONE_PACIENTE

CREATE TABLE telefone_paciente (
    id_paciente INT NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    CONSTRAINT pk_telefone_paciente PRIMARY KEY (id_paciente, telefone),
    CONSTRAINT fk_telefone_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente (id_paciente)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- PROFISSIONAL 

CREATE TABLE profissional (
    id_profissional INT NOT NULL AUTO_INCREMENT,
    cpf CHAR(11) NOT NULL,
    nome VARCHAR(120) NOT NULL,
    data_admissao DATE NOT NULL,
    telefone VARCHAR(20),
    CONSTRAINT pk_profissional PRIMARY KEY (id_profissional),
    CONSTRAINT uq_profissional_cpf UNIQUE (cpf),
    CONSTRAINT ck_profissional_cpf_formato CHECK (cpf REGEXP '^[0-9]{11}$')
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- FISIOTERAPEUTA

CREATE TABLE fisioterapeuta (
    id_profissional INT NOT NULL,
    numero_crefito VARCHAR(20) NOT NULL,                 
    CONSTRAINT pk_fisioterapeuta PRIMARY KEY (id_profissional),
    CONSTRAINT uq_fisioterapeuta_crefito UNIQUE (numero_crefito),
    CONSTRAINT fk_fisioterapeuta_profissional FOREIGN KEY (id_profissional)
        REFERENCES profissional (id_profissional)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- RECEPCIONISTA 

CREATE TABLE recepcionista (
    id_profissional INT NOT NULL,
    ramal VARCHAR(10),
    CONSTRAINT pk_recepcionista PRIMARY KEY (id_profissional),
    CONSTRAINT fk_recepcionista_profissional FOREIGN KEY (id_profissional)
        REFERENCES profissional (id_profissional)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- ADMINISTRATIVO 

CREATE TABLE administrativo (
    id_profissional INT NOT NULL,
    cargo VARCHAR(60) NOT NULL,
    CONSTRAINT pk_administrativo PRIMARY KEY (id_profissional),
    CONSTRAINT fk_administrativo_profissional FOREIGN KEY (id_profissional)
        REFERENCES profissional (id_profissional)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- ESPECIALIDADE

CREATE TABLE especialidade (
    id_especialidade INT NOT NULL AUTO_INCREMENT,
    nome_especialidade VARCHAR(60) NOT NULL,
    descricao TEXT,
    CONSTRAINT pk_especialidade PRIMARY KEY (id_especialidade),
    CONSTRAINT uq_especialidade_nome UNIQUE (nome_especialidade)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- QUALIFICAÇÃO

CREATE TABLE qualificacao (
    id_profissional INT NOT NULL,
    id_especialidade INT NOT NULL,
    data_qualificacao DATE NOT NULL,                          
    CONSTRAINT pk_qualificacao PRIMARY KEY (id_profissional, id_especialidade),
    CONSTRAINT fk_qualificacao_fisioterapeuta FOREIGN KEY (id_profissional)
        REFERENCES fisioterapeuta (id_profissional)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_qualificacao_especialidade FOREIGN KEY (id_especialidade)
        REFERENCES especialidade (id_especialidade)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- CONVENIO

CREATE TABLE convenio (
    id_convenio INT NOT NULL AUTO_INCREMENT,
    nome_convenio VARCHAR(100) NOT NULL,
    registro_ans VARCHAR(20),
    telefone_contato VARCHAR(20),
    CONSTRAINT pk_convenio PRIMARY KEY (id_convenio)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- VINCULO_CONVENIO 

CREATE TABLE vinculo_convenio (
    id_paciente INT NOT NULL,
    id_convenio INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    numero_carteirinha VARCHAR(30) NOT NULL,
    CONSTRAINT pk_vinculo_convenio PRIMARY KEY (id_paciente, id_convenio, data_inicio),
    CONSTRAINT fk_vinculo_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente (id_paciente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_vinculo_convenio FOREIGN KEY (id_convenio)
        REFERENCES convenio (id_convenio)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_vinculo_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- SALA

CREATE TABLE sala (
    id_sala INT NOT NULL AUTO_INCREMENT,
    numero_sala VARCHAR(10) NOT NULL,
    capacidade SMALLINT NOT NULL,
    CONSTRAINT pk_sala PRIMARY KEY (id_sala),
    CONSTRAINT uq_sala_numero UNIQUE (numero_sala),
    CONSTRAINT ck_sala_capacidade CHECK (capacidade > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- EQUIPAMENTO_SALA 

CREATE TABLE equipamento_sala (
    id_sala INT NOT NULL,
    equipamento   VARCHAR(60)  NOT NULL,
    CONSTRAINT pk_equipamento_sala PRIMARY KEY (id_sala, equipamento),
    CONSTRAINT fk_equipamento_sala FOREIGN KEY (id_sala)
        REFERENCES sala (id_sala)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- PROCEDIMENTO 

CREATE TABLE procedimento (
    id_procedimento INT NOT NULL AUTO_INCREMENT,
    nome_procedimento VARCHAR(100) NOT NULL,
    id_especialidade_exigida INT NOT NULL,           
    valor_tabela DECIMAL(10,2) NOT NULL,
    duracao_padrao_min SMALLINT NOT NULL,
    CONSTRAINT pk_procedimento PRIMARY KEY (id_procedimento),
    CONSTRAINT fk_procedimento_especialidade FOREIGN KEY (id_especialidade_exigida)
        REFERENCES especialidade (id_especialidade)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_procedimento_valor CHECK (valor_tabela >= 0),
    CONSTRAINT ck_procedimento_duracao CHECK (duracao_padrao_min > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- COBERTURA 

CREATE TABLE cobertura (
    id_convenio INT NOT NULL,
    id_procedimento INT NOT NULL,
    percentual_cobertura DECIMAL(5,2) NOT NULL,             
    CONSTRAINT pk_cobertura PRIMARY KEY (id_convenio, id_procedimento),
    CONSTRAINT fk_cobertura_convenio FOREIGN KEY (id_convenio)
        REFERENCES convenio (id_convenio)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cobertura_procedimento FOREIGN KEY (id_procedimento)
        REFERENCES procedimento (id_procedimento)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_cobertura_percentual CHECK (percentual_cobertura BETWEEN 0 AND 100)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- AGENDAMENTO 

CREATE TABLE agendamento (
    id_agendamento INT NOT NULL AUTO_INCREMENT,
    id_paciente INT NOT NULL,
    id_fisioterapeuta INT NOT NULL,                    
    id_sala INT NOT NULL,
    data_hora_inicio DATETIME NOT NULL,
    data_hora_fim DATETIME NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'agendado', 
    CONSTRAINT pk_agendamento PRIMARY KEY (id_agendamento),
    CONSTRAINT fk_agendamento_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente (id_paciente)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_agendamento_fisioterapeuta FOREIGN KEY (id_fisioterapeuta)
        REFERENCES fisioterapeuta (id_profissional)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_agendamento_sala FOREIGN KEY (id_sala)
        REFERENCES sala (id_sala)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_agendamento_periodo CHECK (data_hora_fim > data_hora_inicio),
    CONSTRAINT ck_agendamento_status CHECK (status IN ('agendado', 'realizado', 'cancelado'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE INDEX idx_agendamento_fisio_periodo ON agendamento (id_fisioterapeuta, data_hora_inicio, data_hora_fim);  -- RN10
CREATE INDEX idx_agendamento_sala_periodo ON agendamento (id_sala, data_hora_inicio, data_hora_fim);            -- RN11

-- ITEM_AGENDAMENTO 

CREATE TABLE item_agendamento (
    id_agendamento INT NOT NULL,
    id_procedimento INT NOT NULL,
    valor_cobrado DECIMAL(10,2) NOT NULL,                  
    duracao_realizada   SMALLINT,
    CONSTRAINT pk_item_agendamento PRIMARY KEY (id_agendamento, id_procedimento),
    CONSTRAINT fk_item_agendamento_agendamento FOREIGN KEY (id_agendamento)
        REFERENCES agendamento (id_agendamento)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_item_agendamento_procedimento FOREIGN KEY (id_procedimento)
        REFERENCES procedimento (id_procedimento)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_item_agendamento_valor CHECK (valor_cobrado >= 0),
    CONSTRAINT ck_item_agendamento_duracao CHECK (duracao_realizada IS NULL OR duracao_realizada > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- EVOLUCAO 

CREATE TABLE evolucao (
    id_paciente INT NOT NULL,
    num_evolucao SMALLINT NOT NULL,
    data_evolucao DATE NOT NULL,          
    id_agendamento INT NOT NULL,            
    id_fisioterapeuta_responsavel INT NOT NULL,            
    descricao_evolucao TEXT NOT NULL,            
    CONSTRAINT pk_evolucao PRIMARY KEY (id_paciente, num_evolucao),
    CONSTRAINT fk_evolucao_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente (id_paciente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_evolucao_agendamento FOREIGN KEY (id_agendamento)
        REFERENCES agendamento (id_agendamento)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_evolucao_agendamento UNIQUE (id_agendamento),    
    CONSTRAINT fk_evolucao_fisioterapeuta FOREIGN KEY (id_fisioterapeuta_responsavel)
        REFERENCES fisioterapeuta (id_profissional)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_evolucao_num CHECK (num_evolucao > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE INDEX idx_evolucao_fisioterapeuta ON evolucao (id_fisioterapeuta_responsavel);
