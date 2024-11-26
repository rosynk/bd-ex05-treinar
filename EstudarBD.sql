-- Criar o banco de dados
CREATE DATABASE lojaProdutos;
GO

-- Usar o banco de dados
USE lojaProdutos;
GO

-- Criar a tabela de categoria de produtos
CREATE TABLE categoria (
    id INT NOT NULL,
    nome VARCHAR(50) NOT NULL,
    descricao VARCHAR(255) NULL,
    PRIMARY KEY (id)
);
GO

-- Criar a tabela de fornecedor
CREATE TABLE fornecedor (
    id INT NOT NULL,
    nome VARCHAR(50) NOT NULL,
    endereco VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    PRIMARY KEY (id)
);
GO

-- Criar a tabela de produto
CREATE TABLE produto (
    id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255) NULL,
    preco DECIMAL(10, 2) NOT NULL CHECK (preco > 0),
    estoque INT NOT NULL CHECK (estoque >= 0),
    categoria_id INT NOT NULL,
    fornecedor_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (categoria_id) REFERENCES categoria(id),
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedor(id)
);
GO

-- Criar a tabela de venda
CREATE TABLE venda (
    id INT NOT NULL,
    data DATE NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL CHECK (valor_total > 0),
    PRIMARY KEY (id)
);
GO

-- Criar a tabela de item_venda (relacionando produtos com vendas)
CREATE TABLE item_venda (
    venda_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10, 2) NOT NULL CHECK (preco_unitario > 0),
    PRIMARY KEY (venda_id, produto_id),
    FOREIGN KEY (venda_id) REFERENCES venda(id),
    FOREIGN KEY (produto_id) REFERENCES produto(id)
);
GO
-- Inserir categorias
INSERT INTO categoria (id, nome, descricao) VALUES
(1, 'Eletrônicos', 'Produtos eletrônicos como celulares, computadores e acessórios'),
(2, 'Roupas', 'Roupas masculinas e femininas para todos os estilos'),
(3, 'Alimentos', 'Alimentos perecíveis e não perecíveis');
GO

-- Inserir fornecedores
INSERT INTO fornecedor (id, nome, endereco, telefone) VALUES
(1, 'TechCorp', 'Rua da Tecnologia, 100', '1234-5678'),
(2, 'Fashion Store', 'Avenida das Roupas, 200', '2345-6789'),
(3, 'Super Alimentos', 'Estrada dos Alimentos, 300', '3456-7890');
GO

-- Inserir produtos
INSERT INTO produto (id, nome, descricao, preco, estoque, categoria_id, fornecedor_id) VALUES
(1, 'Smartphone XYZ', 'Smartphone com tela de 6.5" e 128GB de armazenamento', 1200.00, 50, 1, 1),
(2, 'Camisa Polo', 'Camisa polo unissex, disponível em várias cores', 59.90, 100, 2, 2),
(3, 'Arroz 5kg', 'Pacote de arroz tipo 1, 5kg', 15.00, 200, 3, 3);
GO

-- Inserir vendas
INSERT INTO venda (id, data, valor_total) VALUES
(1, '2024-11-10', 1259.90),
(2, '2024-11-15', 1180.00);
GO

-- Inserir itens de vendas
INSERT INTO item_venda (venda_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 1200.00),
(1, 2, 1, 59.90),
(2, 3, 2, 15.00);
GO

-- 1. Listar todos os produtos com seus preços e o fornecedor.

SELECT  produto.nome AS Nome_Produto,
		produto.preco AS Preco,
		fornecedor.nome AS Nome_Fornecedor
FROM produto 
INNER JOIN fornecedor ON produto.fornecedor_id = fornecedor.id

-- 2. Encontrar o total de vendas realizadas em um determinado período.
SELECT SUM(v.valor_total) AS Total_Vendas
FROM venda v
WHERE v.data BETWEEN '2024-11-01' AND '2024-11-15';

-- 3. Verificar a quantidade de um determinado produto em estoque.

SELECT  produto.estoque AS quantidade_em_estoque,
		produto.nome AS nome
FROM produto
WHERE produto.nome LIKE 'Arroz 5kg'

-- 4. Listar os produtos que estão acima, ou igual de um valor de estoque de 100 unidades

SELECT  produto.nome AS produto
FROM produto
WHERE produto.estoque >= 100

-- 5. Encontrar o valor total de vendas de cada produto (quantidade vendida * preço unitário).

SELECT 
    produto.nome AS Nome,
    SUM(item_venda.quantidade * produto.preco) AS Valor_Total
FROM produto
INNER JOIN item_venda ON produto.id = item_venda.produto_id
GROUP BY produto.nome;

-- 6. Encontrar as categorias e o número de produtos pertencentes a cada uma.

SELECT  categoria.nome AS Nome_Categoria, 
		SUM(produto.estoque) AS Estoque
FROM categoria
INNER JOIN produto ON categoria_id = produto.categoria_id
GROUP BY categoria.nome

-- 7. Encontrar os fornecedores que têm produtos disponíveis para venda

SELECT DISTINCT fornecedor.nome AS Possui_Produtos_Disp
FROM fornecedor
INNER JOIN produto ON fornecedor.id = produto.fornecedor_id
WHERE produto.estoque > 0

-- 8. Encontrar a venda com o maior valor total.

SELECT  MAX(venda.valor_total) AS Maior_Venda
FROM venda

-- 9. Encontrar o preço médio de todos os produtos.

SELECT AVG( produto.preco ) AS Media_Preco
FROM produto

-- 10. Listar os produtos mais caros.

SELECT  produto.nome AS Nome,
		produto.preco AS Preco 
FROM produto 
ORDER BY produto.preco DESC

-- 11. Encontrar o produto com a maior quantidade em estoque:

SELECT  produto.nome AS Nome,
		produto.estoque AS Estoque
FROM produto 
ORDER BY produto.estoque DESC

-- 12. Contar o número total de produtos em todas as categorias:

SELECT DISTINCT	categoria.nome AS Nome_Categoria,
				SUM(produto.estoque) AS Numero_Estoque
FROM produto
INNER JOIN categoria ON produto.categoria_id = categoria.id
GROUP BY categoria.nome

-- 13. Listar os fornecedores que não possuem produtos associados:

SELECT DISTINCT fornecedor.nome AS Nome
FROM fornecedor
LEFT JOIN produto ON fornecedor.id = produto.fornecedor_id
WHERE produto.estoque IS NULL

-- 14. Determinar a data da primeira venda realizada:

SELECT MIN(venda.data) AS Primeira_Venda
FROM venda

-- 15. Listar os produtos cujos nomes contêm a palavra "Camisa":

SELECT produto.nome AS Produto
FROM produto
WHERE produto.nome LIKE '%Camisa%'

-- 16. Calcular o valor total em estoque (quantidade × preço) de cada produto:
	--por nome
SELECT  SUM(produto.estoque * produto.preco) AS Valor_Total_Estoque,
		produto.nome AS Nome
FROM produto
GROUP BY produto.nome 

	--por categoria
SELECT categoria.nome AS Nome_Categoria,
       SUM(produto.estoque * produto.preco) AS Valor_Total_Estoque
FROM produto
INNER JOIN categoria ON produto.categoria_id = categoria.id
GROUP BY categoria.nome;

-- 17. Listar as vendas realizadas em um intervalo de datas, ordenadas pelo valor total em ordem decrescente:

SELECT venda.id AS ID_Venda,
       venda.valor_total AS Valor_Total,
       venda.data AS Data_Venda
FROM venda
WHERE venda.data BETWEEN '2024-11-01' AND '2024-11-15'
ORDER BY venda.valor_total DESC;

-- 18. Calcular a soma total do valor dos produtos vendidos em cada venda:

SELECT  SUM( venda.valor_total ) AS Soma_Total,
		venda.id AS ID
FROM venda
GROUP BY venda.id

-- 19. Listar os fornecedores e o número de produtos fornecidos por cada um:

SELECT  fornecedor.nome AS Fornecedores,
		SUM(produto.estoque) AS Estoque
FROM fornecedor
INNER JOIN produto ON fornecedor.id = produto.fornecedor_id
GROUP BY fornecedor.nome

-- 20. Encontrar todos os produtos cujos preços estão acima da média dos preços dos produtos:

SELECT produto.nome AS Produto,
       produto.preco AS Preco
FROM produto
WHERE produto.preco > (SELECT AVG(produto.preco) FROM produto);
