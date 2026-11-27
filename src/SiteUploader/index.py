import json
import urllib.request

import boto3


def send_response(event, context, status, reason=None):
    body = {
        "Status": status,
        "Reason": reason or (
            "See CloudWatch Logs: "
            + context.log_group_name
            + " "
            + context.log_stream_name
        ),
        "PhysicalResourceId": context.log_stream_name,
        "StackId": event["StackId"],
        "RequestId": event["RequestId"],
        "LogicalResourceId": event["LogicalResourceId"],
        "Data": {},
    }
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(
        event["ResponseURL"],
        data=data,
        method="PUT",
        headers={"Content-Type": "", "Content-Length": str(len(data))},
    )
    urllib.request.urlopen(req)


def handler(event, context):
    request_type = event["RequestType"]
    props = event["ResourceProperties"]
    bucket = props["BucketName"]
    api_url = props.get("ApiUrl", "")
    s3 = boto3.client("s3")
    try:
        if request_type == "Delete":
            s3.delete_object(Bucket=bucket, Key="index.html")
        else:
            with open("index.html", "r") as f:
                html = f.read()
            html = html.replace("__API_URL__", api_url)
            s3.put_object(
                Bucket=bucket,
                Key="index.html",
                Body=html.encode("utf-8"),
                ContentType="text/html; charset=utf-8",
            )
        send_response(event, context, "SUCCESS")
    except Exception as exc:
        send_response(event, context, "FAILED", reason=str(exc))
    return
