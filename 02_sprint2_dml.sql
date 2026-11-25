/* ============================================================================
   HOMOLOGAÇÃO TÉCNICA: TECHMART CORPORATE SYSTEMS (db_techmart)
   CANDIDATO: Guilherme Tomaz Camara
   TURMA: 1DEV | DATA: 09/12/2026
   ARQUIVO: 02_sprint2_dml.sql
   ============================================================================ */

USE db_techmart;

-- ============================================================================
-- PARTE 2.1 — CARGA DE DADOS (INSERT INTO)
-- ============================================================================

-- 1. Regiões de Atuação
INSERT INTO regioes (id_regiao, nome) VALUES
(1, 'Sudeste'),
(2, 'Sul'),
(3, 'Nordeste');

-- 2. Unidades Filiais
INSERT INTO filiais (id_filial, nome, cidade, id_regiao) VALUES
(10, 'TechMart SP Paulista', 'São Paulo', 1),
(20, 'TechMart RJ Copacabana', 'Rio de Janeiro', 1),
(30, 'TechMart PR Curitiba', 'Curitiba', 2),
(40, 'TechMart PE Recife', 'Recife', 3);

-- 3. Departamentos Internos
INSERT INTO departamentos (id_departamento, nome) VALUES
(1, 'TI & Inovação'),
(2, 'Comercial & Vendas'),
(3, 'Recursos Humanos'),
(4, 'Logística & Suprimentos');

-- 4. Quadro de Colaboradores (Respeitando a hierarquia de supervisão)
INSERT INTO colaboradores (id_colaborador, nome, email, cargo, salario, id_filial, id_departamento, id_supervisor) VALUES
(1, 'Fernando Silva', 'fernando@techmart.com', 'Diretor Geral', 12000.00, 10, 2, NULL);

INSERT INTO colaboradores (id_colaborador, nome, email, cargo, salario, id_filial, id_departamento, id_supervisor) VALUES
(2, 'Roberto Costa', 'roberto@techmart.com', 'Líder de TI', 8500.00, 10, 1, 1),
(4, 'Lucas Oliveira', 'lucas@techmart.com', 'Executivo de Vendas', 4200.00, 10, 2, 1),
(5, 'Camilla Rocha', 'camilla@techmart.com', 'Gerente Regional', 9000.00, 20, 2, 1);

INSERT INTO colaboradores (id_colaborador, nome, email, cargo, salario, id_filial, id_departamento, id_supervisor) VALUES
(3, 'Mariana Souza', 'mariana@techmart.com', 'Analista de Sistemas', 5800.00, 10, 1, 2),
(6, 'Gabriel Santos', 'gabriel@techmart.com', 'Vendedor Pleno', 3400.00, 20, 2, 5),
(7, 'Patricia Melo', 'patricia@techmart.com', 'Analista de RH', 4600.00, 30, 3, 5);

INSERT INTO colaboradores (id_colaborador, nome, email, cargo, salario, id_filial, id_departamento, id_supervisor) VALUES
(8, 'Diego Ferreira', 'diego@techmart.com', 'Trainee Corporativo', 2100.00, 40, NULL, 3);

-- 5. Carteira de Clientes
INSERT INTO clientes (id_cliente, nome, documento, tipo, cidade) VALUES
(101, 'Alpha Tech Solutions SA', '11.222.333/0001-01', 'PJ', 'São Paulo'),
(102, 'Ana Beatriz Nogueira', '123.456.789-00', 'PF', 'São Paulo'),
(103, 'Carlos Eduardo Lopes', '234.567.890-11', 'PF', 'Rio de Janeiro'),
(104, 'SulVarejo Comércio LTDA', '44.555.666/0001-99', 'PJ', 'Curitiba'),
(105, 'Fernanda Vasconcelos', '345.678.901-22', 'PF', 'Belo Horizonte'),
(106, 'Nordeste Digital ME', '77.888.999/0001-55', 'PJ', 'Recife');

-- 6. Categorias de Produtos
INSERT INTO categorias (id_categoria, nome) VALUES
(1, 'Hardware & Notebooks'),
(2, 'Periféricos & Acessórios'),
(3, 'Redes & Servidores'),
(4, 'Mobiliário Corporativo');

-- 7. Catálogo de Produtos
INSERT INTO produtos (id_produto, nome, preco_unitario, quantidade_estoque, id_categoria) VALUES
(1001, 'Notebook Pro Workstation', 6000.00, 20, 1),
(1002, 'SSD NVMe 1TB Ultra', 500.00, 40, 1),
(1003, 'Mouse Vertical Ergonômico', 200.00, 60, 2),
(1004, 'Teclado Mecânico RGB', 400.00, 35, 2),
(1005, 'Switch Gigabit 24 Portas', 1500.00, 12, 3),
(1006, 'Roteador Wi-Fi 6 Mesh', 800.00, 25, 3);

-- 8. Histórico de Pedidos
INSERT INTO pedidos (id_pedido, data_pedido, valor_total, id_filial, id_colaborador, id_cliente) VALUES
(5001, '2026-10-01 10:00:00', 13000.00, 10, 4, 101),
(5002, '2026-10-03 11:30:00', 600.00, 10, 4, 102),
(5003, '2026-10-05 14:15:00', 3000.00, 20, 6, 103),
(5004, '2026-10-10 16:00:00', 1600.00, 30, 7, 104),
(5005, '2026-10-12 09:45:00', 1500.00, 10, 4, 101),
(5006, '2026-10-15 17:20:00', 400.00, 20, 6, NULL);

-- 9. Itens Vendidos dos Pedidos
INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(5001, 1001, 2, 6000.00),
(5001, 1002, 2, 500.00),
(5002, 1003, 1, 200.00),
(5002, 1004, 1, 400.00),
(5003, 1005, 2, 1500.00),
(5004, 1006, 2, 800.00),
(5005, 1002, 3, 500.00),
(5006, 1003, 2, 200.00);


-- ============================================================================
-- PARTE 2.2 — AS 10 CONSULTAS DA DIRETORIA (SELECT)
-- ============================================================================

-- ===================================================
-- DEMANDA 01: Desempenho das Lojas
-- ===================================================
SELECT 
    f.nome AS filial,
    COUNT(p.id_pedido) AS total_pedidos,
    IFNULL(SUM(p.valor_total), 0.00) AS faturamento_total,
    IFNULL(AVG(p.valor_total), 0.00) AS ticket_medio
FROM filiais f
LEFT JOIN pedidos p ON f.id_filial = p.id_filial
GROUP BY f.id_filial, f.nome
ORDER BY faturamento_total DESC;

-- ===================================================
-- DEMANDA 02: Capital Parado em Estoque
-- ===================================================
SELECT 
    c.nome AS categoria,
    COUNT(p.id_produto) AS qtd_produtos_diferentes,
    SUM(p.preco_unitario * p.quantidade_estoque) AS valor_financeiro_estoque
FROM categorias c
INNER JOIN produtos p ON c.id_categoria = p.id_categoria
GROUP BY c.id_categoria, c.nome
HAVING SUM(p.preco_unitario * p.quantidade_estoque) > 25000.00;

-- ===================================================
-- DEMANDA 03: Auditoria de Vendas Identificadas
-- ===================================================
SELECT 
    p.id_pedido AS numero_pedido,
    p.data_pedido,
    c.nome AS cliente,
    c.tipo AS tipo_cliente,
    f.nome AS filial,
    col.nome AS vendedor,
    p.valor_total
FROM pedidos p
INNER JOIN clientes c ON p.id_cliente = c.id_cliente
INNER JOIN filiais f ON p.id_filial = f.id_filial
INNER JOIN colaboradores col ON p.id_colaborador = col.id_colaborador
ORDER BY p.id_pedido;

-- ===================================================
-- DEMANDA 04: Custo de Pessoal por Área
-- ===================================================
SELECT 
    d.nome AS departamento,
    COUNT(c.id_colaborador) AS qtd_funcionarios,
    IFNULL(SUM(c.salario), 0.00) AS custo_folha_salarial
FROM departamentos d
LEFT JOIN colaboradores c ON d.id_departamento = c.id_departamento
GROUP BY d.id_departamento, d.nome
ORDER BY custo_folha_salarial DESC;

-- ===================================================
-- DEMANDA 05: Revisão do Catálogo de Categorias
-- ===================================================
SELECT 
    c.nome AS categoria,
    p.nome AS produto,
    p.preco_unitario
FROM produtos p
RIGHT JOIN categorias c ON p.id_categoria = c.id_categoria
ORDER BY c.id_categoria, p.nome;

-- ===================================================
-- DEMANDA 06: Mapa de Liderança (Quem é chefe de quem)
-- ===================================================
SELECT 
    col.nome AS colaborador,
    col.cargo AS cargo_colaborador,
    col.salario,
    IFNULL(sup.nome, 'Sem Supervisor (Diretoria)') AS supervisor,
    IFNULL(sup.cargo, '-') AS cargo_supervisor
FROM colaboradores col
LEFT JOIN colaboradores sup ON col.id_supervisor = sup.id_colaborador
ORDER BY col.id_colaborador;

-- ===================================================
-- DEMANDA 07: Salários Acima do Padrão da Empresa
-- ===================================================
SELECT 
    c.nome AS colaborador,
    c.cargo,
    c.salario,
    f.nome AS filial
FROM colaboradores c
INNER JOIN filiais f ON c.id_filial = f.id_filial
WHERE c.salario > (SELECT AVG(salario) FROM colaboradores)
ORDER BY c.salario DESC;

-- ===================================================
-- DEMANDA 08a: Campanha de Marketing — Clientes Ativos (Fidelização)
-- ===================================================
SELECT 
    c.id_cliente AS codigo,
    c.nome,
    c.cidade
FROM clientes c
WHERE EXISTS (
    SELECT 1 
    FROM pedidos p 
    WHERE p.id_cliente = c.id_cliente
);

-- ===================================================
-- DEMANDA 08b: Campanha de Marketing — Clientes Inativos (Reativação)
-- ===================================================
SELECT 
    c.id_cliente AS codigo,
    c.nome,
    c.cidade
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1 
    FROM pedidos p 
    WHERE p.id_cliente = c.id_cliente
);

-- ===================================================
-- DEMANDA 09: Mapeamento Geográfico Unificado
-- ===================================================
SELECT 
    nome,
    cidade,
    'Cliente' AS origem
FROM clientes
UNION ALL
SELECT 
    nome,
    cidade,
    'Filial' AS origem
FROM filiais;

-- ===================================================
-- DEMANDA 10: Premiação de Vendedores Destaque
-- ===================================================
WITH VendasPorVendedor AS (
    SELECT 
        c.id_colaborador,
        c.nome AS vendedor,
        SUM(p.valor_total) AS total_vendido
    FROM colaboradores c
    INNER JOIN pedidos p ON c.id_colaborador = p.id_colaborador
    GROUP BY c.id_colaborador, c.nome
)
SELECT 
    vendedor,
    total_vendido
FROM VendasPorVendedor
WHERE total_vendido > (SELECT AVG(total_vendido) FROM VendasPorVendedor)
ORDER BY total_vendido DESC;