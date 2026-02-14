# AWS QuickSight Dashboard Embedding Infrastructure

Este repositório contém a infraestrutura como código (IaC) utilizando **Terraform** para expor um dashboard do Amazon QuickSight em uma aplicação web estática, de forma segura e escalável.



## 🏗️ Arquitetura

A solução utiliza os seguintes componentes:
* **Front-end:** HTML/JavaScript hospedado em um bucket **S3** privado.
* **Entrega:** **CloudFront** com **OAC (Origin Access Control)** para servir o conteúdo globalmente com HTTPS.
* **Backend (Auth):** **API Gateway (HTTP API)** integrado a uma função **Lambda**.
* **Integração:** A Lambda solicita uma URL de embedding ao **QuickSight** utilizando permissões do IAM para um usuário registrado.
* **Visualização:** O SDK do QuickSight renderiza o dashboard no cliente final.

## 🚀 Pré-requisitos

1.  **AWS CLI** configurado com as devidas permissões.
2.  **Terraform** instalado (v1.0+).
3.  **QuickSight Enterprise Edition** (necessário para recursos de embedding).
4.  Um **Dashboard** já publicado no QuickSight.
5.  O **ARN do Usuário** do QuickSight que terá permissão de visualização.

## 📁 Estrutura do Projeto

```text
.
├── terraform/
│   ├── main.tf          # Recursos principais (S3, CloudFront, API GW)
│   ├── lambda.tf        # Definição da função Lambda e IAM Roles
│   ├── variables.tf     # Definição das variáveis de entrada
│   └── outputs.tf       # Links e IDs gerados após o deploy
├── src/
│   ├── index.html       # Front-end da aplicação
│   └── lambda_function.py # Código Python da Lambda
└── deploy.sh            # Script utilitário para automação


🛠️ Como Implantar
1. Preparar a Lambda
Zipe o arquivo da função antes de iniciar:

Bash
zip src/lambda_function.zip src/lambda_function.py
2. Configurar Variáveis
Crie um arquivo terraform.tfvars na pasta terraform/ com seus dados:

Terraform
account_id          = "123456789012"
quicksight_user_arn = "arn:aws:quicksight:us-east-1:123456789012:user/default/seu-usuario"
dashboard_id        = "seu-uuid-do-dashboard"

3. Aplicar o Terraform
Bash
terraform init
terraform apply
4. Upload do Front-end
Após o apply, o Terraform exibirá a URL da API e o nome do bucket. Atualize a URL da API no arquivo index.html e suba-o para o S3:

Bash
aws s3 cp src/index.html s3://$(terraform output -raw s3_bucket_name)/
🔒 Segurança
Bucket Privado: O S3 não possui acesso público. Todo acesso é via CloudFront OAC.

CORS: O API Gateway está configurado para aceitar requisições apenas da origem do seu CloudFront.

Least Privilege: A Role da Lambda possui permissão restrita apenas para o Dashboard e Usuário informados.

📝 Notas de Localidade
O dashboard está configurado no index.html para carregar com o locale pt-BR, garantindo que os controles e filtros estejam em português brasileiro.

Desenvolvido como um modelo de arquitetura serveless para BI.