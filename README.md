# Totem de Pedidos - Database Infrastructure

![GitHub](https://img.shields.io/badge/GitHub-FIAP--11SOAT-blue)
![Terraform](https://img.shields.io/badge/Terraform-v1.0+-purple)
![AWS](https://img.shields.io/badge/AWS-RDS-orange)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17.5-blue)

Este projeto contém a infraestrutura de banco de dados para o sistema de **Totem de Pedidos** da FIAP - Pós-graduação em Software Architecture (11SOAT). O projeto implementa uma solução robusta usando PostgreSQL na AWS RDS, provisionada via Terraform.

## 📋 Visão Geral

O sistema de Totem de Pedidos é uma aplicação para gerenciamento de pedidos em restaurantes e lanchonetes, permitindo:
- Gestão de clientes e pedidos
- Catálogo de produtos por categoria
- Processamento de pagamentos
- Controle de status dos pedidos

## 🏗️ Arquitetura

- **Banco de Dados**: PostgreSQL 17.5
- **Cloud Provider**: AWS RDS
- **Infrastructure as Code**: Terraform
- **Região**: us-east-1 (configurável)

## 🛠️ Pré-requisitos

Antes de começar, certifique-se de ter instalado em sua máquina:

### Ferramentas Necessárias
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado
- Cliente PostgreSQL (psql ou similar) para executar migrações
- Git

### Credenciais AWS
- Acesso à conta AWS com permissões para:
  - RDS (criação e gerenciamento de instâncias)
  - VPC (acesso a VPCs e subnets existentes)
  - EC2 (criação de security groups)
- AWS CLI configurado com `aws configure` ou variáveis de ambiente

### Infraestrutura Existente
Este projeto assume que você já possui:
- Uma VPC nomeada como `infra-totem-de-pedidos-vpc`
- Subnets dentro da VPC

## ⚙️ Configuração

### 1. Clone o Repositório
```bash
git clone https://github.com/FIAP-11SOAT/fase3-database-totem-de-pedidos.git
cd fase3-database-totem-de-pedidos
```

### 2. Configure as Variáveis do Terraform
Crie um arquivo `terraform.tfvars` no diretório `deployTerraform/`:

```hcl
aws_region   = "us-east-1"
project_name = "fase3-database-totem-de-pedidos"
```

### 3. Configuração de Credenciais AWS
```bash
# Opção 1: AWS CLI
aws configure

# Opção 2: Variáveis de ambiente
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_SESSION_TOKEN="your-session-token"  # se usando AWS Academy/Learner Lab
```

## 🚀 Deploy da Infraestrutura

### 1. Inicializar o Terraform
```bash
cd deployTerraform
terraform init
```

### 2. Planejar o Deploy
```bash
terraform plan
```

### 3. Aplicar as Mudanças
```bash
terraform apply
```

Confirme com `yes` quando solicitado.

### 4. Obter Informações da Conexão
Após o deploy, você pode obter as informações de conexão:
```bash
# Endpoint do RDS
terraform output rds_endpoint

# Senha do banco (cuidado ao executar em ambientes não seguros)
terraform output rds_password
```

## 📚 Migrações do Banco de Dados

Após o deploy da infraestrutura, execute o script de migração:

### 1. Conectar ao Banco
```bash
psql -h <rds_endpoint> -U infra_totem_de_pedidos_admin -d infra_totem_de_pedidos_database
```

### 2. Executar o Script de Migração
```bash
psql -h <rds_endpoint> -U infra_totem_de_pedidos_admin -d infra_totem_de_pedidos_database -f migration/NovoScript.sql
```

### 3. Verificar as Tabelas Criadas
```sql
-- Listar todas as tabelas
\dt

-- Verificar dados de exemplo
SELECT * FROM product_categories;
SELECT * FROM products;
```

## 🗂️ Estrutura do Projeto

```
├── README.md                          # Este arquivo
├── assets/
│   └── modelo_de_dados.png           # Diagrama ER do banco de dados
├── deployTerraform/                  # Configurações do Terraform
│   ├── rds.tf                        # Configuração do RDS PostgreSQL
│   ├── variables.tf                  # Variáveis e data sources
│   ├── terraform.tfvars.example      # Exemplo de configuração
│   └── terraform/                    # Estado do Terraform
└── migration/
    └── NovoScript.sql                # Script de criação das tabelas
```

## 📊 Modelo de Dados

Este documento também explica a modelagem do banco de dados proposta, destacando as alterações feitas em relação ao modelo original, as melhorias de performance implementadas e a justificativa para a escolha do **PostgreSQL** como tecnologia.

### Diagrama ER
O diagrama completo do modelo de dados está disponível em: [`assets/modelo_de_dados.png`](./assets/modelo_de_dados.png)

---

## 📊 Documentação Detalhada do Modelo de Dados

### Entidades Principais

#### 1. Customers
**Objetivo:** Armazenar informações de clientes.  

- **Chaves únicas:** `email` e `tax_id` → garantem que não haja duplicidade de cadastro.  
- **Campos adicionais:** `phone` foi adicionado para facilitar contato direto.  

---

#### 2. Payments
**Objetivo:** Registrar pagamentos.  

### Alterações Feitas em Relação ao Modelo Original
- **Chave primária**  
  - Antes: `serial primary key`  
  - Agora: `bigserial primary key` → suporta maior volume de dados.  

- **Índices únicos**  
  - Antes: constraints estavam misturadas no `CREATE TABLE` e também no `ALTER TABLE`.  
  - Agora: criados no momento da tabela, sem redundância.  

- **Índices adicionais explícitos**  
  - PostgreSQL já cria índices em PK e UNIQUE, mas não em FK.  
  - Foram adicionados índices em colunas usadas em **joins** e consultas frequentes.  

- **Check constraints**  
  - Evitam dados inválidos em campos como `amount`, `status`, etc.  

- **Campos de busca frequente**  
  - Índices criados em `status`, `payment_date` e `transaction_code`.  

---

#### 3. Orders
**Objetivo:** Controlar pedidos dos clientes.  

- **Relacionamentos:**  
  - Cada pedido pertence a um cliente (`ON DELETE CASCADE`).  
  - Pode ter um pagamento associado (`ON DELETE SET NULL`).  

- **Check constraints:**  
  - Evitam valores negativos em totais e garantem consistência.  

- **Índices:**  
  - Criados em `customer_id`, `payment_id`, `status` e `order_date`.  

---

#### 4. Product Categories
**Objetivo:** Categorizar os produtos.  

- **Restrição:** `name` único.  

---

#### 5. Products
**Objetivo:** Catálogo de produtos disponíveis.  

- **Relacionamento:** Cada produto pertence a uma categoria.  
- **Check constraints:** Impedem preços negativos ou tempo de entrega inválido.  
- **Índices criados:**  
  - `name` e `category_id` para buscas.  
  - `price` para filtros e ordenações.  

---

#### 6. Order Items
**Objetivo:** Produtos associados a um pedido.  

- **Restrição:** (`order_id`, `product_id`) único → evita repetição do mesmo produto em um pedido.  
- **Índices criados:** `order_id` e `product_id` para acelerar joins.  

---

### Otimizações de Performance

#### Justificativas dos Índices
- **Chaves estrangeiras (FKs):**  
  Criados em `orders.customer_id`, `orders.payment_id`, `products.category_id`, `order_items.order_id` e `order_items.product_id`.  
  Ganho: aceleração de **joins** frequentes.  

- **Campos de busca:**  
  - `customers.name` → útil em buscas/autocomplete.  
  - `payments.status`, `orders.status` → filtros em relatórios.  
  - Datas (`order_date`, `payment_date`, `created_at`) → filtros por período.  

- **Produtos:**  
  - `products.price` → para filtros (`WHERE price BETWEEN ...`) e ordenações (`ORDER BY price`).  

    Resultado: consultas mais rápidas em listagens, filtros e relatórios, sem necessidade de varredura completa da tabela (full scan).  

---

### Justificativa Técnica

#### Escolha do PostgreSQL
O **PostgreSQL** foi escolhido por oferecer:  

- **Confiabilidade e robustez** → usado em sistemas críticos (financeiro, e-commerce, bancário).  
- **Recursos avançados** → suporte a transações ACID, constraints poderosas (CHECK, UNIQUE, FK) e JSON/JSONB.  
- **Escalabilidade** → indexação avançada (B-Tree, GIN, BRIN) e excelente performance em consultas complexas.  
- **Open source** → comunidade ativa, sem custos de licenciamento.  
- **Extensibilidade** → criação de funções em SQL, PL/pgSQL, Python, etc.  

---

### Resumo das Melhorias

#### Conclusão
O modelo foi ajustado para:  
- Melhorar **performance** (com índices explícitos e bem posicionados).  
- Garantir **consistência** (check constraints e regras de negócio).  
- Aumentar a **escalabilidade** e suportar grandes volumes de dados.  
- Preparar o sistema para consultas complexas e relatórios frequentes.  

Essas alterações deixam o banco de dados mais confiável, eficiente e pronto para aplicações críticas em ambientes reais.

## 🔧 Troubleshooting

### Problemas Comuns

#### Erro de Conexão com RDS
```bash
# Verificar se o RDS está rodando
aws rds describe-db-instances --db-instance-identifier fase3-database-totem-de-pedidos-rds-postgres

# Testar conectividade
telnet <rds_endpoint> 5432
```

#### Erro de Permissões AWS
- Verifique se as credenciais AWS estão configuradas corretamente
- Confirme se o usuário/role tem as permissões necessárias para RDS, VPC e EC2

#### VPC não encontrada
- Certifique-se de que existe uma VPC com o nome `infra-totem-de-pedidos-vpc`
- Verifique se está na região correta

### Comandos Úteis

#### Destruir a Infraestrutura
```bash
cd deployTerraform
terraform destroy
```

#### Verificar Estado do Terraform
```bash
terraform show
terraform state list
```

#### Backup do Banco
```bash
pg_dump -h <rds_endpoint> -U infra_totem_de_pedidos_admin infra_totem_de_pedidos_database > backup.sql
```

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é parte do curso de Pós-graduação em Software Architecture da FIAP.

## 👥 Equipe

- **FIAP 11SOAT** - *Desenvolvimento inicial*

## 📚 Referências

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)

---

**Nota**: Este projeto foi desenvolvido como parte da Fase 3 do curso de Software Architecture da FIAP, focando em infraestrutura como código e melhores práticas de banco de dados.
