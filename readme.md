# AWS QuickSight Dashboard Embedding Infrastructure

Este repositório contém a infraestrutura como código (IaC) utilizando **Terraform** para expor um dashboard do Amazon QuickSight em uma aplicação web estática, de forma segura e escalável.


## 🏗️ Arquitetura

A solução utiliza os seguintes componentes:
* **Front-end:** HTML/JavaScript hospedado em um bucket **S3** privado.
* **Entrega:** **CloudFront** com **OAC (Origin Access Control)** para servir o conteúdo globalmente com HTTPS.
* **Backend (Auth):** **API Gateway (HTTP API)** integrado a uma função **Lambda**.
* **Integração:** A Lambda solicita uma URL de embedding ao **QuickSight** utilizando permissões do IAM para um usuário registrado.
* **Visualização:** O SDK do QuickSight renderiza o dashboard no cliente final.
* **CI/CD:** Github Actions para implantar esteira de deploy na AWS
* **Terraform State:** Utilização de bucket S3 para o tfstate do terraform

## 🚀 Pré-requisitos

1.  **QuickSight Enterprise Edition** (necessário para recursos de embedding).
3.  Um **Dashboard** já publicado no QuickSight.
4.  O **ARN do Usuário** do QuickSight que terá permissão de visualização.
5. Apos deploy da infra adicionar o **Distribution domain name** ou seu dominio em *Manage domains* no Gerenciamento do QuickSight

## 📁 Estrutura do Projeto

```text
.
├── terraform/
│   ├── main.tf          # Recursos principais (S3, CloudFront, API GW)
│   ├── lambda.tf        # Definição da função Lambda e IAM Roles
│   ├── variables.tf     # Definição das variáveis de entrada
│   ├── outputs.tf       # Links e IDs gerados após o deploy
|   └── demais_recursos.tf # Separei demais recurso em outros arquivos .tf
├── src/
│   ├── index.html       # Front-end da aplicação
│   └── lambda_function.py # Código Python da Lambda
└── .github/workflows/deploy.yml            # Script utilitário para automação


🔒 Segurança
Bucket Privado: O S3 não possui acesso público. Todo acesso é via CloudFront OAC.

CORS: O API Gateway está configurado para aceitar requisições apenas da origem do seu CloudFront.

Least Privilege: A Role da Lambda possui permissão restrita apenas para o Dashboard e Usuário informados.

TF_VAR: definir variáveis de ambiente que o Terraform reconhece automaticamente como valores para suas variáveis de entrada (input variables). Isso permite passar credenciais ou configurações sensíveis, armazenadas nos segredos do GitHub, diretamente para o terraform plan ou apply.

📝 Notas de Localidade
O dashboard está configurado no index.html para carregar com o locale pt-BR, garantindo que os controles e filtros estejam em português brasileiro.

Desenvolvido como um modelo de arquitetura serveless para BI.