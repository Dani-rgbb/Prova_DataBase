1 - SGBD: O PostgreSQL (ou outro SGBD relacional) é a melhor escolha porque garante transações seguras, integridade referencial e confiabilidade dos registros acadêmicos, características essenciais em sistemas educacionais.

Organização: Schemas são uma camada extra de organização e segurança dentro de um SGBD relacional. Eles permitem aplicar políticas de acesso diferenciadas, manter a integridade dos dados em ambientes complexos e alinhar a arquitetura do banco às práticas de governança corporativa.

2 - Esquema do Modelo Lógico
Schema: academico
🟨 Tabela alunos
Coluna	        Tipo de dado	     Restrições 	Descrição
id_matricula	INTEGER	             PRIMARY KEY    Identificador único do aluno
nome_usuario	VARCHAR(100)	     NOT NULL	    Nome completo do aluno
email_usuario	VARCHAR(100)	     UNIQUE,NOT NULL	E-mail institucional
endereco_usuario VARCHAR(150)	     NULL	        Cidade e estado do aluno
data_ingresso	DATE	             NOT NULL	    Data de ingresso no curso
🟦 Tabela disciplinas
Coluna	                Tipo de dado	Restrições	   Descrição
cod_servico_academico	VARCHAR(10)	    PRIMARY KEY	   Código da disciplina
nome_disciplina	        VARCHAR(100)	NOT NULL	   Nome da disciplina
carga_h	                INTEGER	        NOT NULL	Carga horária total
🟩 Tabela docentes
Coluna	        Tipo de dado	Restrições	Descrição
id_docente	    SERIAL	        PRIMARY KEY	Identificador único do docente
nome_docente	VARCHAR(100)	NOT NULL	Nome do professor responsável
🟧 Tabela operadores_pedagogicos
Coluna	                       Tipo de dado	 Restrições	  Descrição
matricula_operador_pedagogico  VARCHAR(10)	 PRIMARY KEY  Identificador do operador
nome_operador	               VARCHAR(100)	 NULL	      Nome do operador pedagógico
⚙️ Tabela matriculas_disciplina
Coluna	               Tipo de dado	  Restrições	                     Descrição
id_matricula	       INTEGER	      FOREIGN KEY → alunos(id_matricula) Aluno matriculado
cod_servico_academico  VARCHAR(10)	  FOREIGN KEY → disciplinas(cod_servico_academico)	Disciplina cursada
id_docente	INTEGER	FOREIGN KEY → docentes(id_docente)	Professor responsável
matricula_operador_pedagogico	VARCHAR(10)	FOREIGN KEY → operadores_pedagogicos(matricula_operador_pedagogico)	Operador vinculado
score_final	NUMERIC(3,1)	CHECK (score_final BETWEEN 0 AND 10)	Nota final do aluno
ciclo_calendario	VARCHAR(10)	NOT NULL	Período letivo (ex: 2026/1)
Chave primária composta:  
PRIMARY KEY (id_matricula, cod_servico_academico)

🔐 Relacionamentos
Relacionamento	Tipo	Cardinalidade
alunos → matriculas_disciplina	1:N	Um aluno pode ter várias matrículas
disciplinas → matriculas_disciplina	1:N	Uma disciplina pode ter vários alunos
docentes → matriculas_disciplina	1:N	Um docente pode lecionar várias disciplinas
operadores_pedagogicos → matriculas_disciplina	1:N	Um operador pode acompanhar várias matrículas
Resumo técnico:

Todas as tabelas estão em 3ª Forma Normal (3NF).

As chaves primárias e estrangeiras garantem integridade referencial.

O uso de schemas (como academico) organiza o banco e facilita controle de acesso.

O modelo é totalmente compatível com PostgreSQL, podendo ser implementado diretamente via script SQL.

5 - 🔹 Isolamento (ACID)
O Isolamento garante que cada transação seja executada como se fosse a única no sistema, mesmo que várias ocorram simultaneamente.

No exemplo, dois operadores tentam alterar a nota do mesmo aluno ao mesmo tempo. O SGBD assegura que:

Uma transação não “enxerga” alterações parciais da outra.

O resultado final será equivalente a uma execução sequencial (primeiro uma, depois a outra), evitando dados corrompidos ou inconsistentes.

🔹 Locks (Bloqueios)
O PostgreSQL (e outros SGBDs relacionais) usam locks para controlar concorrência.

Quando um operador inicia a atualização da nota (UPDATE), o SGBD coloca um lock exclusivo na linha correspondente (row-level lock).

Isso significa que:

Enquanto a primeira transação não terminar (commit ou rollback), a segunda transação que tenta alterar a mesma linha fica bloqueada e precisa esperar.

Assim, evita-se que duas alterações simultâneas gerem um valor incorreto ou sobrescrevam dados sem controle.

🔹 Resultado prático
Operador A inicia a transação e altera a nota → lock exclusivo na linha do aluno.

Operador B tenta alterar a mesma nota → fica em espera até que o lock seja liberado.

Quando o lock é liberado, a transação do Operador B é aplicada sobre o dado já consistente.

O banco garante que não haverá “corrida” de dados (race condition) e que o histórico de transações permanece íntegro.

✅ Conclusão:  
O Isolamento assegura que cada transação seja independente e consistente, enquanto os Locks impedem alterações simultâneas conflitantes. Juntos, eles garantem que o dado final seja confiável, preservando a integridade acadêmica e evitando corrupção de registros.