import json
import boto3
import os
import logging

# Configuração do Logger para o CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    client = boto3.client('quicksight')
    
    # Captura das variáveis de ambiente
    try:
        dashboard_id = os.environ['DASHBOARD_ID']
        account_id = os.environ['ACCOUNT_ID']
        user_arn_input = os.environ['USER_ARN']
        region = os.environ['REGION']
        
        # Montagem do ARN do Usuário (ajuste conforme o que você passa no Terraform)
        if user_arn_input.startswith('arn:aws:quicksight'):
            user_arn = user_arn_input
        else:
            user_arn = f'arn:aws:quicksight:{region}:{account_id}:user/default/{user_arn_input}'
            
    except KeyError as e:
        logger.error(f"❌ Erro de configuração: Variável de ambiente não encontrada: {str(e)}")
        return error_response(f"Erro de configuração interna", 500)

    logger.info(f"🚀 Iniciando geração de URL para o dashboard: {dashboard_id}")
    logger.info(f"👤 Usuário Quicksight: {user_arn}")

    try:
        response = client.generate_embed_url_for_registered_user(
            AwsAccountId=account_id,
            UserArn=user_arn,
            ExperienceConfiguration={
                'Dashboard': {
                    'InitialDashboardId': dashboard_id
                }
            }
        )
        
        # Log de sucesso explícito
        logger.info("✅ Embed URL gerada com sucesso!")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'embedUrl': response['EmbedUrl'],
                'status': 'success'
            })
        }
        
    except client.exceptions.AccessDeniedException as e:
        logger.error(f"🚫 Acesso Negado: Verifique as políticas do IAM ou se o usuário tem permissão no Dashboard. Detalhes: {str(e)}")
        return error_response("Acesso Negado ao QuickSight", 403)
        
    except client.exceptions.ResourceNotFoundException as e:
        logger.error(f"🔍 Recurso não encontrado: Dashboard ID {dashboard_id} pode estar incorreto. Detalhes: {str(e)}")
        return error_response("Dashboard não encontrado", 404)
        
    except Exception as e:
        # O exc_info=True adiciona o rastreamento completo do erro (Traceback) ao log
        logger.error(f"💥 Erro inesperado: {str(e)}", exc_info=True)
        return error_response("Erro interno ao processar a URL", 500)

def error_response(message, code):
    """Função auxiliar para padronizar respostas de erro"""
    return {
        'statusCode': code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({'error': message, 'status': 'failed'})
    }