import json
import boto3
import os
import logging
logger = logging.getLogger()

def lambda_handler(event, context):
    client = boto3.client('quicksight')
    
    # Substitua pelos seus dados ou use variáveis de ambiente
    dashboard_id = os.environ['DASHBOARD_ID']
    account_id = os.environ['ACCOUNT_ID']
    user_arn = os.environ['USER_ARN']
    region = os.environ['REGION']
    
    try:
        response = client.generate_embed_url_for_registered_user(
            AwsAccountId=account_id,
            UserArn=f'arn:aws:quicksight:{region}:{account_id}:user/default/{user_arn}',
            ExperienceConfiguration={
                'Dashboard': {
                    'InitialDashboardId': dashboard_id
                }
            }
        )
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*' # Importante para o CORS
            },
            'body': json.dumps({'embedUrl': response['EmbedUrl']})
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    
# ####################
# somente contas pagas quick
# ###################
        # #### anonymous user - only pricy session
        # response = client.generate_embed_url_for_anonymous_user(
        #     AwsAccountId=account_id,
        #     Namespace='default',
        #     AuthorizedResourceArns=[
        #         f'arn:aws:quicksight:{region}:{account_id}:dashboard/{dashboard_id}'
        #     ],
        #     ExperienceConfiguration={
        #         'Dashboard': {
        #             'InitialDashboardId': dashboard_id
        #         }
        #     }
        # )