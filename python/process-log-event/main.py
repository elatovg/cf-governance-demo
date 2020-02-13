import base64
import json
import os
from google.cloud import storage
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail


def process_log_entry(data, context):
    data_buffer = base64.b64decode(data['data'])
    log_entry = json.loads(data_buffer)['protoPayload']

    print(data)
    print(context)

    # resource = log_entry['resourceName']
    requestor = log_entry['authenticationInfo']['principalEmail']
    bucket = json.loads(data_buffer)['resource']['labels']['bucket_name']
    role = log_entry['serviceData']['policyDelta']['bindingDeltas'][0]['role']
    member = log_entry['serviceData']['policyDelta']['bindingDeltas'][0]['member']

    print("Method: {}".format(log_entry['methodName']))
    print("Resource: {}".format(log_entry['resourceName']))
    print("Initiator: {}".format(log_entry['authenticationInfo']['principalEmail']))

    remove_bucket_iam_member(bucket, role, member)
    subject = "IAM Policy Removed for AllUsers Role"
    body = "User '{}' added role '{}' to AllUsers to bucket '{}' and was reverted".format(
        requestor, role, bucket)
    send_mail(body, subject)


def remove_bucket_iam_member(bucket_name, role, member):
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)

    policy = bucket.get_iam_policy()
    policy[role].discard(member)
    bucket.set_iam_policy(policy)

    print('Removed {} with role {} from {}.'.format(
        member, role, bucket_name))


def send_mail(msg_body, msg_subject):

    message = Mail(
        from_email='cf@@sink.sendgrid.net',
        to_emails=os.environ.get('RECIPIENT'),
        subject=msg_subject,
        html_content=msg_body)
    try:
        sg_client = SendGridAPIClient(os.environ.get('SG_API_KEY'))
        response = sg_client.send(message)
        # Uncomment for extra debug info
        # print(response.status_code)
        # print(response.body)
        # print(response.headers)
        print('Email Successfully sent with status code: {}.'.format(response.status_code))
    except Exception as e:
        print(e.message)


'''
    # old version of the sg lib
    to_email = os.environ.get('RECIPIENT')
    sg = sendgrid.SendGridAPIClient(apikey=os.environ.get('SENDGRID_API_KEY'))
    from_email = Email("cf@@sink.sendgrid.net")
    to_email = Email(to_email)
    subject = "IAM Policy Removed for AllUsers Role"
    cnt = Content("text/plain", msg_body)
    sg_mail = Mail(from_email, subject, to_email, cnt)
    response = sg.client.mail.send.post(request_body=sg_mail.get())
    For Troubleshooting
    print(response.status_code)
    print(response.body)
    print(response.headers)
'''