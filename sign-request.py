import botocore.session
from botocore.awsrequest import create_request_object
import json
import base64
import sys

def headers_to_go_style(headers):
    retval = {}
    for k, v in headers.items():
        retval[k] = v.decode('utf-8') if isinstance(v, bytes) else v
    return retval

def generate_vault_request(awsIamServerId):
    session = botocore.session.get_session()
    client = session.create_client('sts')
    endpoint = client._endpoint
    operation_model = client._service_model.operation_model('GetCallerIdentity')
    request_dict = client._convert_to_request_dict({}, operation_model)

    request_dict['headers']['X-Vault-AWS-IAM-Server-ID'] = awsIamServerId

    request = endpoint.create_request(request_dict, operation_model)

    return base64.b64encode(bytes(json.dumps(headers_to_go_style(dict(request.headers))), 'utf-8')).decode('utf-8')

if __name__ == "__main__":
    awsIamServerId = sys.argv[1]
    print(generate_vault_request(awsIamServerId))