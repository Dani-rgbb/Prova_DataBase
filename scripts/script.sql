-- =========================================================
-- 1. NAMESPACES
-- =========================================================
CREATE SCHEMA academico;
CREATE SCHEMA seguranca;

-- =========================================================
-- 2. ESTRUTURA (DDL)
-- =========================================================

-- Tabela de Alunos
CREATE TABLE academico.alunos (
    id_matricula INTEGER PRIMARY KEY,
    nome_usuario VARCHAR(100) NOT NULL,
    email_usuario VARCHAR(100) UNIQUE NOT NULL,
    endereco_usuario VARCHAR(150),
    data_ingresso DATE NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Disciplinas
CREATE TABLE academico.disciplinas (
    cod_servico_academico VARCHAR(10) PRIMARY KEY,
    nome_disciplina VARCHAR(100) NOT NULL,
    carga_h INTEGER NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Docentes
CREATE TABLE academico.docentes (
    id_docente SERIAL PRIMARY KEY,
    nome_docente VARCHAR(100) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Operadores Pedagógicos
CREATE TABLE academico.operadores_pedagogicos (
    matricula_operador_pedagogico VARCHAR(10) PRIMARY KEY,
    nome_operador VARCHAR(100),
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Matrículas por Disciplina
CREATE TABLE academico.matriculas_disciplina (
    id_matricula INTEGER REFERENCES academico.alunos(id_matricula),
    cod_servico_academico VARCHAR(10) REFERENCES academico.disciplinas(cod_servico_academico),
    id_docente INTEGER REFERENCES academico.docentes(id_docente),
    matricula_operador_pedagogico VARCHAR(10) REFERENCES academico.operadores_pedagogicos(matricula_operador_pedagogico),
    score_final NUMERIC(3,1) CHECK (score_final BETWEEN 0 AND 10),
    ciclo_calendario VARCHAR(10) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_matricula, cod_servico_academico)
);

-- =========================================================
-- 3. GOVERNANÇA (SOFT DELETE)
-- =========================================================
-- Em vez de DELETE físico, usar UPDATE para marcar como inativo:
-- Exemplo:
-- UPDATE academico.alunos SET ativo = FALSE WHERE id_matricula = 2026001;

-- =========================================================
-- 4. SEGURANÇA (DCL)
-- =========================================================

-- Criação de perfis
CREATE ROLE professor_role;
CREATE ROLE coordenador_role;

-- Permissões do coordenador: acesso total
GRANT ALL PRIVILEGES ON SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON SCHEMA seguranca TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA academico TO coordenador_role;

-- Permissões do professor: apenas UPDATE na coluna de notas
GRANT SELECT, UPDATE(score_final) ON academico.matriculas_disciplina TO professor_role;

-- Privacidade: professor não pode acessar e-mails dos alunos
REVOKE SELECT ON COLUMN academico.alunos.email_usuario FROM professor_role;

-- =========================================================
-- 5. POPULAÇÃO DE DADOS (DML)
-- =========================================================
-- Inserção dos dados da planilha legada
-- (Exemplo simplificado — os dados completos devem ser carregados via script ETL ou COPY FROM)

INSERT INTO academico.alunos (id_matricula, nome_usuario, email_usuario, endereco_usuario, data_ingresso)
VALUES
(2026001, 'Ana Beatriz Lima', 'ana.lima@aluno.edu.br', 'Braganca Paulista/SP', '2026-01-20'),
(2026002, 'Bruno Henrique Souza', 'bruno.souza@aluno.edu.br', 'Atibaia/SP', '2026-01-21'),
(2026003, 'Camila Ferreira', 'camila.ferreira@aluno.edu.br', 'Jundiai/SP', '2026-01-22'),
(2026004, 'Diego Martins', 'diego.martins@aluno.edu.br', 'Campinas/SP', '2026-01-23'),
(2026005, 'Eduarda Nunes', 'eduarda.nunes@aluno.edu.br', 'Itatiba/SP', '2026-01-24'),
(2026006, 'Felipe Araujo', 'felipe.araujo@aluno.edu.br', 'Louveira/SP', '2026-01-25'),
(2025010, 'Gabriela Torres', 'gabriela.torres@aluno.edu.br', 'Nazare Paulista/SP', '2025-08-05'),
(2025011, 'Helena Rocha', 'helena.rocha@aluno.edu.br', 'Piracaia/SP', '2025-08-06'),
(2025012, 'Igor Santana', 'igor.santana@aluno.edu.br', 'Jarinu/SP', '2025-08-07');

-- Inserção de disciplinas
INSERT INTO academico.disciplinas (cod_servico_academico, nome_disciplina, carga_h)
VALUES
('ADS101', 'Banco de Dados', 80),
('ADS102', 'Engenharia de Software', 80),
('ADS103', 'Algoritmos', 60),
('ADS104', 'Redes de Computadores', 60),
('ADS105', 'Sistemas Operacionais', 60),
('ADS106', 'Estruturas de Dados', 80);

-- Inserção de docentes
INSERT INTO academico.docentes (nome_docente)
VALUES
('Prof. Carlos Mendes'),
('Profa. Juliana Castro'),
('Prof. Renato Alves'),
('Profa. Marina Lopes'),
('Prof. Eduardo Pires'),
('Prof. Ricardo Faria');

-- Inserção de operadores pedagógicos
INSERT INTO academico.operadores_pedagogicos (matricula_operador_pedagogico, nome_operador)
VALUES
('OP8999', 'Operador A'),
('OP9000', 'Operador B'),
('OP9001', 'Operador C'),
('OP9002', 'Operador D'),
('OP9003', 'Operador E'),
('OP9004', 'Operador F');

-- Inserção de matrículas por disciplina (exemplo)
INSERT INTO academico.matriculas_disciplina (id_matricula, cod_servico_academico, id_docente, matricula_operador_pedagogico, score_final, ciclo_calendario)
VALUES
(2026001, 'ADS101', 1, 'OP9001', 9.1, '2026/1'),
(2026001, 'ADS102', 2, 'OP9001', 8.4, '2026/1'),
(2026002, 'ADS103', 3, 'OP9002', 6.8, '2026/1'),
(2026003, 'ADS106', 6, 'OP9001', 6.1, '2026/1'),
(2025010, 'ADS101', 1, 'OP8999', 6.4, '2025/2'),
(2025011, 'ADS104', 4, 'OP8999', 7.9, '2025/2'),
(2025012, 'ADS105', 5, 'OP9000', 5.5, '2025/2');

-- =========================================================
-- Fim do Script
-- =========================================================
 Queries

 1. Listagem de Matriculados
Nome dos alunos, nomes das disciplinas e ciclo, filtrando apenas pelo ciclo 2026/1.

sql
SELECT a.nome_usuario, d.nome_disciplina, m.ciclo_calendario
FROM academico.matriculas_disciplina m
JOIN academico.alunos a ON m.id_matricula = a.id_matricula
JOIN academico.disciplinas d ON m.cod_servico_academico = d.cod_servico_academico
WHERE m.ciclo_calendario = '2026/1';
2. Baixo Desempenho
Média de notas por disciplina, listando apenas aquelas cuja média geral seja inferior a 6.0.

sql
SELECT d.nome_disciplina, AVG(m.score_final) AS media_notas
FROM academico.matriculas_disciplina m
JOIN academico.disciplinas d ON m.cod_servico_academico = d.cod_servico_academico
GROUP BY d.nome_disciplina
HAVING AVG(m.score_final) < 6.0;
3. Alocação de Docentes
Liste todos os docentes e suas respectivas disciplinas, garantindo que docentes sem turmas vinculadas também apareçam (LEFT JOIN).

sql
SELECT doc.nome_docente, dis.nome_disciplina
FROM academico.docentes doc
LEFT JOIN academico.matriculas_disciplina m ON doc.id_docente = m.id_docente
LEFT JOIN academico.disciplinas dis ON m.cod_servico_academico = dis.cod_servico_academico
ORDER BY doc.nome_docente;
4. Destaque Acadêmico
Nome do aluno e o valor da nota do maior desempenho registrado na disciplina de "Banco de Dados" (Subconsulta).

sql
SELECT a.nome_usuario, m.score_final
FROM academico.matriculas_disciplina m
JOIN academico.alunos a ON m.id_matricula = a.id_matricula
JOIN academico.disciplinas d ON m.cod_servico_academico = d.cod_servico_academico
WHERE d.nome_disciplina = 'Banco de Dados'
  AND m.score_final = (
      SELECT MAX(m2.score_final)
      FROM academico.matriculas_disciplina m2
      JOIN academico.disciplinas d2 ON m2.cod_servico_academico = d2.cod_servico_academico
      WHERE d2.nome_disciplina = 'Banco de Dados'
  );