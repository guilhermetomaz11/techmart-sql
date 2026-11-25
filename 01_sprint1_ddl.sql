/* ============================================================================
   HOMOLOGAÇÃO TÉCNICA: TECHMART CORPORATE SYSTEMS (db_techmart)
   CANDIDATO: Guilherme Tomaz Camara
   TURMA: 1DEV | DATA: 09/12/2026
   ARQUIVO: 01_sprint1_ddl.sql
   ============================================================================ */

DROP DATABASE IF EXISTS db_techmart;
CREATE DATABASE db_techmart;
USE db_techmart;

-- ==========================================
-- 1. TABELAS INDEPENDENTES (PAI)
-- ==========================================

-- Regiões geográficas de atuação
CREATE TABLE regioes (
    id_regiao INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

-- Departamentos internos da empresa
CREATE TABLE departamentos (
    id_departamento INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

-- Categorias de produtos
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

-- Carteira de Clientes
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    documento VARCHAR(20) NOT NULL UNIQUE, -- CPF ou CNPJ único
    tipo ENUM('PF', 'PJ') NOT NULL,
    cidade VARCHAR(100) NOT NULL
);

-- ==========================================
-- 2. TABELAS DEPENDENTES (FILHAS)
-- ==========================================

-- Filiais conectadas às regiões
CREATE TABLE filiais (
    id_filial INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL UNIQUE,
    cidade VARCHAR(100) NOT NULL,
    id_regiao INT NOT NULL,
    CONSTRAINT fk_filiais_regioes FOREIGN KEY (id_regiao) REFERENCES regioes(id_regiao)
);

-- Colaboradores
CREATE TABLE colaboradores (
    id_colaborador INT AUTO_INCREMENT PRIMARY KEY, -- Código de matrícula
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE, -- E-mail corporativo exclusivo
    cargo VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    id_filial INT NOT NULL,
    id_departamento INT NULL, -- Opcional para estagiários/trainees em rotação
    id_supervisor INT NULL,   -- Auto-relacionamento (Diretoria Geral fica NULL)
    CONSTRAINT fk_colaboradores_filiais FOREIGN KEY (id_filial) REFERENCES filiais(id_filial),
    CONSTRAINT fk_colaboradores_departamentos FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento),
    CONSTRAINT fk_colaboradores_supervisor FOREIGN KEY (id_supervisor) REFERENCES colaboradores(id_colaborador)
);

-- Catálogo de Produtos
CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL UNIQUE,
    preco_unitario DECIMAL(10,2) NOT NULL,
    quantidade_estoque INT NOT NULL DEFAULT 0, -- Inicia em zero se não for informado
    id_categoria INT NOT NULL,
    CONSTRAINT fk_produtos_categorias FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- Pedidos (Vendas)
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10,2) DEFAULT 0.00, -- Inicia em zero
    id_filial INT NOT NULL,
    id_colaborador INT NOT NULL,
    id_cliente INT NULL, -- Pode ser NULL caso o cliente não queira se identificar no balcão
    CONSTRAINT fk_pedidos_filiais FOREIGN KEY (id_filial) REFERENCES filiais(id_filial),
    CONSTRAINT fk_pedidos_colaboradores FOREIGN KEY (id_colaborador) REFERENCES colaboradores(id_colaborador),
    CONSTRAINT fk_pedidos_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Itens do Pedido
CREATE TABLE itens_pedido (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_itens_pedidos FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_itens_produtos FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- Log de Auditoria Interna de Operações
CREATE TABLE log_auditoria_operacoes (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo_operacao VARCHAR(50) NOT NULL,
    descricao TEXT NOT NULL,
    usuario_banco VARCHAR(100) NOT NULL
);