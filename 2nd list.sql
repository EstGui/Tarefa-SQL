-------------------------- Procedure de exclusão de aluno --------------------------

-- Crie uma procedure que receba o ID de um aluno como parâmetro e exclua o registro 
-- correspondente na tabela de alunos. Além disso, todas as matrículas associadas ao 
-- aluno devem ser removidas.

CREATE OR REPLACE PACKAGE BODY pkg_gestao_alunos IS

    PROCEDURE encerrar_matricula(
        aluno_id IN VARCHAR2,
    ) IS
    BEGIN
        DELETE FROM matriculas WHERE id_aluno = aluno_id;
        DELETE FROM alunos WHERE id_aluno = aluno_id;

        DBMS_OUTPUT.PUT_LINE('Matricula encerrada com sucesso: ' || aluno_id);
    END encerrar_matricula;

END pkg_gestao_alunos;
------------------------------------------------------------------------------------



----------------- Cursor de listagem de alunos maiores de 18 anos: -----------------

-- Desenvolva um cursor que liste o nome e a data de nascimento de todos os alunos 
-- com idade superior a 18 anos.

DECLARE
    CURSOR cur_alunos IS
        SELECT nome, data_nascimento FROM aluno
        WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, p_data_nascimento) / 12) > 18;

    v_nome VARCHAR2(50);
    v_data_nascimento DATE;
BEGIN
    OPEN cur_alunos;

    LOOP
        FETCH cur_alunos INTO v_nome, v_data_nascimento;
        EXIT WHEN cur_alunos%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Nome do Aluno: ' || v_nome || ', Data de Nascimento: ' || v_data_nascimento);
    END LOOP;

    CLOSE cur_alunos;
END;
------------------------------------------------------------------------------------



--------------------------- Cursor com filtro por curso: ---------------------------

-- Crie um cursor parametrizado que receba o id_curso e exiba os nomes dos alunos 
-- matriculados no curso especificado.

DECLARE
    CURSOR cur_alunos_curso(p_id_curso NUMBER) IS
        SELECT a.nome
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        JOIN disciplina d ON m.id_disciplina = d.id_disciplina
        WHERE d.id_curso = p_id_curso;

    v_nome VARCHAR2(50);
BEGIN
    OPEN cur_alunos_curso(1);

    LOOP
        FETCH cur_alunos_curso INTO v_nome;
        EXIT WHEN cur_alunos_curso%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Nome do Aluno: ' || v_nome);
    END LOOP;

    CLOSE cur_alunos_curso;
END;
------------------------------------------------------------------------------------




----------------------- Procedure de cadastro de disciplina: -----------------------

-- Crie uma procedure para cadastrar uma nova disciplina. A procedure deve receber
-- como parâmetros o nome, a descrição e a carga horária da disciplina e inserir 
-- esses dados na tabela correspondente.

CREATE OR REPLACE PROCEDURE cadastrar_disciplina(
    p_nome IN VARCHAR2,
    p_descricao IN VARCHAR2,
    p_carga_horaria IN NUMBER(5, 2),
)
IS
BEGIN
    INSERT INTO disciplina (nome, descricap, carga_horaria)
    VALUES (p_nome, p_descricao, p_carga_horaria);
    
    DBMS_OUTPUT.PUT_LINE('Disciplina cadastrado com sucesso: ' || p_nome);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro inesperado ao cadastrar o aluno.');
END cadastrar_aluno;
------------------------------------------------------------------------------------



-------------------- Cursor para total de alunos por disciplina --------------------

-- Implemente um cursor que percorra as disciplinas e exiba o número total de alunos
-- matriculados em cada uma. Exiba apenas as disciplinas com mais de 10 alunos.

DECLARE
    CURSOR cur_disciplinas IS
        SELECT d.nome AS disciplina, COUNT(m.id_matricula) AS total_alunos
        FROM disciplina d
        JOIN matricula m ON d.id_disciplina = m.id_disciplina
        GROUP BY d.nome;

    v_disciplina VARCHAR2(50);
    v_total_alunos NUMBER;
BEGIN
    OPEN cur_disciplinas;

    LOOP
        FETCH cur_disciplinas INTO v_disciplina, v_total_alunos;
        EXIT WHEN cur_disciplinas%NOTFOUND;

        IF v_total_alunos > 10 THEN
            DBMS_OUTPUT.PUT_LINE('Disciplina: ' || v_disciplina || ', Total de Alunos: ' || v_total_alunos);
        END IF;

    END LOOP;

    CLOSE cur_disciplinas;
END;
------------------------------------------------------------------------------------



--------------------- Cursor com média de idade por disciplina ---------------------

-- Desenvolva um cursor parametrizado que receba o id_disciplina e calcule a média de
-- idade dos alunos matriculados na disciplina especificada.

CURSOR c_media_idade(p_id_disciplina NUMBER) IS
    SELECT AVG(TRUNC(MONTHS_BETWEEN(SYSDATE, p_data_nascimento) / 12)) AS media_idade
    FROM matriculas m
    JOIN alunos a ON m.id_aluno = a.id_aluno
    WHERE m.id_disciplina = p_id_disciplina;

BEGIN
    OPEN c_media_idade(1);

    FETCH c_media_idade INTO v_media_idade;
    CLOSE c_media_idade;

    DBMS_OUTPUT.PUT_LINE('Média de idade dos alunos: ' || NVL(v_media_idade, 0));
END;
------------------------------------------------------------------------------------



------------------ Procedure para listar alunos de uma disciplina ------------------

-- Implemente uma procedure que receba o ID de uma disciplina como parâmetro e exiba
-- os nomes dos alunos matriculados nela.

CREATE OR REPLACE PROCEDURE exibir_nomes(disciplina_id IN NUMBER) IS
BEGIN
    FOR aluno IN (
        SELECT a.nome
        FROM matriculas m
        JOIN alunos a ON m.aluno_id = a.id
        WHERE m.disciplina_id = disciplina_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Aluno: ' || aluno.nome);
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum aluno encontrado para a disciplina com ID ' || disciplina_id || '.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocorreu um erro inesperado: ' || SQLERRM);
END;
------------------------------------------------------------------------------------




-------------------- Cursor para total de turmas por professor: --------------------

-- Desenvolva um cursor que liste os nomes dos professores e o total de turmas que 
-- cada um leciona. O cursor deve exibir apenas os professores responsáveis por mais
-- de uma turma.

DECLARE
    CURSOR c_professores_turmas IS
        SELECT p.nome, COUNT(d.id) AS total_turmas
        FROM professores p
        JOIN disciplinas d ON p.id = d.professor_id
        GROUP BY p.nome
        HAVING COUNT(d.id) > 1;

    v_nome_professor professores.nome%TYPE;
    v_total_turmas NUMBER;
BEGIN
    OPEN c_professores_turmas;
    LOOP
        FETCH c_professores_turmas INTO v_nome_professor, v_total_turmas;
        EXIT WHEN c_professores_turmas%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Professor: ' || v_nome_professor || ', Total de Turmas: ' || v_total_turmas);
    END LOOP;

    CLOSE c_professores_turmas;
END;
------------------------------------------------------------------------------------



------------------ Function para total de turmas de um professor: ------------------

-- Crie uma function que receba o ID de um professor como parâmetro e retorne o 
-- total de turmas em que ele atua como responsável.

CREATE OR REPLACE FUNCTION total_turmar_professor(p_id_professor NUMBER)
RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM turma
    WHERE id_professor = p_id_professor;

    RETURN v_total;
END total_turmar_professor;
------------------------------------------------------------------------------------



-------------------- Function para professor de uma disciplina: --------------------

-- Desenvolva uma function que receba o ID de uma disciplina como parâmetro e retorne
-- o nome do professor que ministra essa disciplina.

CREATE OR REPLACE FUNCTION obter_nome_professor(p_id_disciplina IN NUMBER)
RETURN VARCHAR2
IS
    v_nome_professor VARCHAR2(100);
BEGIN
    SELECT p.nome
    INTO v_nome_professor
    FROM disciplinas d
    JOIN professores p ON d.id_professor = p.id
    WHERE d.id = p_id_disciplina;

    RETURN v_nome_professor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Disciplina ou professor não encontrado.';
    WHEN OTHERS THEN
        RETURN 'Erro ao buscar o professor: ' || SQLERRM;
END;
------------------------------------------------------------------------------------
