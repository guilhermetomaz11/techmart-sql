# 🏆 Homologação Técnica em Banco de Dados Relacional (`db_techmart`)

**Empresa Proponente (Contexto):** *TechMart Corporate Systems*  
**Unidade Curricular:** Banco de Dados Relacionais — Modelagem, Implementação, Programação e Administração  
**Metodologia:** Metodologia SENAI de Educação Profissional (MSEP)  
**Natureza da Avaliação:** Avaliação Somativa Integradora (Individual e Autônoma)  

---

## 📋 1. Contexto Empresarial e Problema de Negócio

A **TechMart Corporate Systems** é uma rede nacional de tecnologia e equipamentos corporativos em rápida expansão. Anteriormente, cada filial controlava suas vendas, seu estoque e sua equipe em planilhas isoladas, ocasionando falhas operacionais críticas:

* **Furo de Estoque:** Produtos eram vendidos sem saldo disponível.
* **Redundância e Duplicidade:** Clientes e categorias eram cadastrados com nomes e documentos duplicados.
* **Falta de Rastreabilidade Hierárquica:** A diretoria não conseguia cruzar quem vendeu o quê, em qual filial e quem supervisionava cada colaborador.
* **Vulnerabilidade e Falta de Auditoria:** Qualquer funcionário conseguia alterar preços sem deixar rastro e não existiam rotinas de cópia de segurança (*backup* e *restore*).

**Objetivo do Projeto:** Projetar, implementar, povoar, automatizar e blindar o banco de dados corporativo **`db_techmart`** normalizado na **3ª Forma Normal (3FN)**, garantindo integridade referencial, inteligência de negócios via consultas analíticas (DQL), automação via SGBD e políticas de controle de acesso (DCL).

---

## 📂 2. Estrutura de Arquivos e Entrega

O pacote final de entrega deve ser compactado no formato `.ZIP` seguindo o padrão `Nome_Sobrenome_TechMart.zip` e conter rigorosamente os **4 arquivos SQL** abaixo:

```text
📦 Nome_Sobrenome_TechMart.zip
 ┣ 📜 01_sprint1_ddl.sql             # Estrutura Física do Banco (Criação de Schema, Tabelas, PKs, FKs e Restrições)
 ┣ 📜 02_sprint2_dml_dql.sql         # Carga Inicial de Dados (DML) + 10 Relatórios Gerenciais da Diretoria (DQL)
 ┣ 📜 03_sprint3_automacao_dcl.sql   # Stored Procedure, Function, Triggers, Controle de Acesso (DCL) e Logs de Teste
 ┗ 📜 04_backup_db_techmart_full.sql # Cópia de Contingência Completa gerada via mysqldump (--routines --triggers)
```

---

## 🧱 3. Arquitetura e Modelagem de Dados (Sprint 1 — DDL)

O banco de dados **`db_techmart`** é composto por **10 tabelas** estruturadas na 3ª Forma Normal (3FN), divididas entre entidades independentes (pai) e dependentes (filhas):

### 3.1. Dicionário de Dados e Regras de Negócio

| Tabela | Descrição e Regras de Integridade |
| :--- | :--- |
| **`regioes`** | Regiões geográficas de atuação (Sudeste, Sul, Nordeste). Possui `id_regiao` (PK) e `nome` (`UNIQUE`, `NOT NULL`). |
| **`filiais`** | Unidades físicas da rede. Possui `id_filial` (PK), `nome` (`UNIQUE`), `cidade` e vínculo obrigatório com `regioes` (`id_regiao` FK). |
| **`departamentos`** | Setores internos (TI, Comercial, RH, Logística). Possui `id_departamento` (PK) e `nome` (`UNIQUE`). |
| **`colaboradores`** | Quadro de funcionários com `id_colaborador` (PK), `nome`, `email` (`UNIQUE`), `cargo`, `salario`, vínculo obrigatório com `filiais` (`id_filial` FK), vínculo **opcional** (`NULL`) com `departamentos` (para estagiários/trainees em rotação) e **auto-relacionamento** via `id_supervisor` (`FK` apontando para a própria tabela `colaboradores`; apenas a Diretoria Geral possui `NULL`). |
| **`clientes`** | Carteira de clientes com `id_cliente` (PK), `nome`, `documento` (`UNIQUE` para CPF/CNPJ), `tipo` (`ENUM('PF', 'PJ')`) e `cidade`. |
| **`categorias`** | Agrupamento de mercadorias com `id_categoria` (PK) e `nome` (`UNIQUE`). |
| **`produtos`** | Catálogo comercial com `id_produto` (PK), `nome` (`UNIQUE`), `preco_unitario`, `quantidade_estoque` (`DEFAULT 0`) e vínculo com `categorias` (`id_categoria` FK). |
| **`pedidos`** | Registro de vendas com `id_pedido` (PK), `data_pedido` (`DEFAULT CURRENT_TIMESTAMP`), `valor_total` (`DEFAULT 0.00`), vínculos obrigatórios com `filiais` e `colaboradores`, e vínculo **opcional** (`NULL`) com `clientes` (permitindo vendas anônimas no balcão). |
| **`itens_pedido`** | Detalhamento dos produtos vendidos em cada pedido (`id_item` PK, `id_pedido` FK com `ON DELETE CASCADE`, `id_produto` FK, `quantidade` e `preco_unitario` praticado no momento da venda). |
| **`log_auditoria_operacoes`** | Tabela de rastreabilidade interna que registra `id_log` (PK), `data_hora`, `tipo_operacao`, `descricao` e `usuario_banco`. |

---

## 📊 4. Carga Operacional e Inteligência de Negócio (Sprint 2 — DML & DQL)

### 4.1. Resumo da Carga Inicial (`INSERT INTO`)
A carga respeita rigorosamente a hierarquia de chaves estrangeiras (sem desativar `FOREIGN_KEY_CHECKS`):
* **3 Regiões** (Sudeste, Sul, Nordeste) e **4 Filiais** (SP Paulista, RJ Copacabana, PR Curitiba, PE Recife).
* **4 Departamentos** (incluindo *Logística & Suprimentos* sem colaboradores alocados).
* **8 Colaboradores** em 4 níveis hierárquicos (do Diretor Geral *Fernando Silva* ao Trainee *Diego Ferreira*, sem departamento fixo).
* **6 Clientes** (4 ativos com histórico de compras e 2 cadastrados sem pedidos: *Fernanda Vasconcelos* e *Nordeste Digital ME*).
* **4 Categorias** (incluindo *Mobiliário Corporativo* sem produtos) e **6 Produtos** cadastrados.
* **6 Pedidos** (5 identificados e 1 venda anônima de balcão — Pedido `5006`) e **8 Itens de Pedido**.

### 4.2. As 10 Demandas Gerenciais Respondidas (DQL)

1. **Desempenho das Lojas:** Ranking de faturamento total, quantidade de pedidos e ticket médio por filial (`LEFT JOIN`, `COUNT`, `SUM`, `AVG`, `GROUP BY`, `ORDER BY`).
2. **Capital Parado em Estoque:** Identificação de categorias cujo valor financeiro estocado (`preco_unitario * quantidade_estoque`) ultrapassa **R$ 25.000,00** (`INNER JOIN`, `GROUP BY`, `HAVING`).
3. **Auditoria de Vendas Identificadas:** Cruzamento completo de pedidos com clientes identificados, excluindo vendas anônimas de balcão (`INNER JOIN` múltiplo entre `pedidos`, `clientes`, `filiais` e `colaboradores`).
4. **Custo de Pessoal por Área:** Levantamento da quantidade de funcionários e folha salarial de **todos** os departamentos, incluindo setores vazios (`LEFT JOIN` a partir de `departamentos`).
5. **Revisão do Catálogo de Categorias:** Exibição de todas as categorias (inclusive sem produtos) mantendo `produtos` à esquerda e `categorias` à direita (`RIGHT JOIN`).
6. **Mapa de Liderança (Organograma):** Cruzamento entre colaboradores e seus respectivos supervisores imediatos, incluindo o Diretor Geral (`SELF JOIN` com `LEFT JOIN`).
7. **Salários Acima do Padrão da Empresa:** Listagem de colaboradores cuja remuneração supera a média salarial global da *TechMart* (Subconsulta escalar com `AVG` no `WHERE`).
8. **Campanha de Marketing (Ativos vs. Inativos):**
   * **8a (Fidelização):** Clientes com histórico de compras comprovado (`EXISTS`).
   * **8b (Reativação):** Clientes cadastrados que nunca realizaram pedidos (`NOT EXISTS`).
9. **Mapeamento Geográfico Unificado:** Consolidação em lista única de nomes e cidades de Clientes e Filiais com coluna identificadora de origem (`UNION ALL`).
10. **Premiação de Vendedores Destaque:** Criação de tabela temporária lógica para identificar vendedores cujo volume de vendas superou a média da equipe comercial (`CTE` — *Common Table Expression* com `WITH`).

---

## ⚙️ 5. Automação, Segurança e Contingência (Sprint 3 — Rotinas, DCL & Backup)

### 5.1. Programação no SGBD
* **Stored Procedure (`sp_aplicar_desconto_categoria`):** Aplica reajuste percentual promocional em massa nos produtos de uma categoria específica.
* **User Defined Function (`fn_classificar_fidelidade_cliente`):** Classifica o perfil de compra do cliente com base no volume acumulado de pedidos.
* **Triggers de Blindagem e Auditoria (`BEFORE INSERT`, `AFTER INSERT`, `AFTER UPDATE` / `AFTER DELETE`):**
  * Impedem vendas quando a quantidade solicitada excede o saldo disponível em estoque (`SIGNAL SQLSTATE '45000'`).
  * Atualizam automaticamente o saldo de estoque e os totais dos pedidos.
  * Registram rastros de alterações críticas na tabela `log_auditoria_operacoes`.

### 5.2. Controle de Acesso e Privilégios Mínimos (DCL)
Configuração de perfis isolados de segurança (`CREATE USER`, `GRANT`, `REVOKE`, `FLUSH PRIVILEGES`):
* **`admin_dba`:** Privilégios administrativos totais sobre `db_techmart`.
* **`gerente_comercial`:** Permissões de consulta, inserção e atualização, com revogação explícita de exclusão (`REVOKE DELETE`).
* **`operador_pdv`:** Acesso restrito estritamente às operações de frente de caixa (`pedidos` e `itens_pedido`).

---

## 🚀 6. Guia de Execução e Auditoria Técnica

Para reproduzir o ambiente limpo e validar a entrega:

1. **Criação da Estrutura (Sprint 1):**
   Execute o arquivo `01_sprint1_ddl.sql` por completo no MySQL Workbench ou CLI para recriar o schema `db_techmart` do zero.
2. **Carga de Dados e Relatórios (Sprint 2):**
   Execute o arquivo `02_sprint2_dml_dql.sql` por completo. *(Importante: deve ser executado antes das Triggers da Sprint 3 para não recalcular o estoque e os totais do histórico já consolidado).*
3. **Automação e Segurança (Sprint 3):**
   Execute o arquivo `03_sprint3_automacao_dcl.sql` para ativar a *Procedure*, a *Function*, as *Triggers* e os usuários de acesso.
4. **Geração da Cópia de Contingência (Backup Completo):**
   No terminal do sistema operacional, execute o utilitário `mysqldump` incluindo rotinas e gatilhos:
   ```bash
   mysqldump -u root -p --routines --triggers db_techmart > 04_backup_db_techmart_full.sql
   ```
5. **Teste de Restauração (Restore):**
   ```bash
   mysql -u root -p db_techmart < 04_backup_db_techmart_full.sql
   ```

---

## ✅ 7. Matriz de Avaliação (100 Pontos)

| Etapa / Sprint | Escopo Avaliado pela Auditoria Técnica | Pontuação |
| :--- | :--- | :---: |
| **Sprint 1** (`01_sprint1_ddl.sql`) | Modelagem 3FN, criação das 10 tabelas, PKs, FKs, `UNIQUE`, `DEFAULT` e auto-relacionamento de supervisão. | **30 pts** |
| **Sprint 2** (`02_sprint2_dml_dql.sql`) | Carga de dados íntegra na ordem hierárquica (10 pts) + Precisão das 10 demandas gerenciais (25 pts). | **35 pts** |
| **Sprint 3** (`03` e `04`) | Stored Procedure (8 pts), Function (5 pts), Triggers de Estoque (10 pts), Perfis DCL (6 pts) e Backup/Restore completo (6 pts). | **35 pts** |
| **TOTAL** | **Nota Mínima para Homologação Plena: 70 pontos** | **100 pts** |#   t e c h m a r t - s q l  
 