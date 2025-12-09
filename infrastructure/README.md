# DTW Docs - AWS Infrastructure

Infraestrutura Terraform para hospedar site estático no S3 com CloudFront e certificado SSL.

## Arquitetura

- **S3 Bucket**: Armazenamento dos arquivos estáticos
- **CloudFront**: CDN para distribuição global com HTTPS
- **ACM Certificate**: Certificado SSL/TLS gratuito
- **Route53**: DNS para o subdomínio dtw-docs.usa.matera.systems

## Pré-requisitos

- Terraform >= 1.0
- AWS CLI configurado com credenciais válidas
- Acesso à conta AWS com a hosted zone `usa.matera.systems`
- Permissões para criar recursos S3, CloudFront, ACM e Route53

## Estrutura de Arquivos

```
infrastructure/
├── main.tf                      # Recursos principais
├── variables.tf                 # Variáveis parametrizáveis
├── outputs.tf                   # Outputs do Terraform
├── terraform.tfvars.example     # Exemplo de variáveis
├── deploy.sh                    # Script de deploy completo
├── sync-site.sh                 # Script para sincronizar apenas os arquivos
├── destroy.sh                   # Script para destruir a infraestrutura
└── README.md                    # Esta documentação
```

## Configuração

1. Copie o arquivo de exemplo de variáveis:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edite `terraform.tfvars` se necessário (os valores padrão já estão configurados).

## Deploy Inicial

Execute o script de deploy que fará todo o processo automaticamente:

```bash
cd infrastructure
chmod +x deploy.sh
./deploy.sh
```

O script irá:
1. Inicializar o Terraform
2. Criar/validar certificado SSL
3. Criar bucket S3 e CloudFront
4. Configurar DNS no Route53
5. Fazer upload dos arquivos do site
6. Invalidar cache do CloudFront

**Nota**: O primeiro deploy pode levar 15-20 minutos devido à criação da distribuição CloudFront e validação do certificado SSL.

## Atualização do Site

Para atualizar apenas os arquivos do site sem modificar a infraestrutura:

```bash
cd infrastructure
chmod +x sync-site.sh
./sync-site.sh
```

## Comandos Terraform Manuais

### Inicializar
```bash
terraform init
```

### Planejar mudanças
```bash
terraform plan
```

### Aplicar infraestrutura
```bash
terraform apply
```

### Visualizar outputs
```bash
terraform output
```

### Sincronizar arquivos manualmente
```bash
aws s3 sync ../site s3://dtw-docs.usa.matera.systems --delete
```

### Invalidar cache do CloudFront
```bash
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

## Destruição da Infraestrutura

Para remover todos os recursos AWS:

```bash
cd infrastructure
chmod +x destroy.sh
./destroy.sh
```

**⚠️ ATENÇÃO**: Esta ação é irreversível e removerá todos os recursos e arquivos!

## Variáveis Configuráveis

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `aws_region` | Região AWS principal | `us-east-1` |
| `project_name` | Nome do projeto | `dtw-docs` |
| `domain_name` | Domínio completo do site | `dtw-docs.usa.matera.systems` |
| `hosted_zone_name` | Hosted zone do Route53 | `usa.matera.systems` |
| `site_path` | Caminho para os arquivos do site | `../site` |
| `tags` | Tags AWS para os recursos | Ver `variables.tf` |

## Outputs

Após o deploy, os seguintes valores estarão disponíveis:

- `bucket_name`: Nome do bucket S3
- `cloudfront_distribution_id`: ID da distribuição CloudFront
- `cloudfront_domain_name`: Domínio do CloudFront
- `site_url`: URL final do site (https://dtw-docs.usa.matera.systems)
- `certificate_arn`: ARN do certificado SSL

## Custos Estimados

- S3: ~$0.023/GB armazenado + $0.09/GB transferido
- CloudFront: Tier gratuito 1TB/mês, depois ~$0.085/GB
- Route53: $0.50/hosted zone/mês + $0.40/milhão queries
- ACM: Gratuito

Para site de documentação pequeno: **~$1-5/mês**

## Troubleshooting

### Certificado SSL não valida
- Aguarde até 30 minutos para validação DNS
- Verifique os registros DNS no Route53

### CloudFront não atualiza
- Execute invalidação: `./sync-site.sh`
- Cache pode levar até 24h para expirar naturalmente

### Erro de permissões
- Verifique credenciais AWS
- Confirme permissões IAM necessárias

## Segurança

- Certificado SSL/TLS gerenciado pela AWS
- HTTPS forçado via CloudFront
- Bucket S3 configurado apenas para leitura pública dos objetos
- Todas as comunicações criptografadas
