import boto3
import cfnresponse as c
import json

ssm = boto3.client("ssm")

def create(ev, ctx):
  props = ev["ResourceProperties"]

  name = props["Name"]
  if name is None:
    raise Exception("Missing required parameter: Name")

  description = props["Description"]
  if description is None:
    raise Exception("Missing required parameter: Description")

  value = props["Value"]
  if value is None:
    raise Exception("Missing required parameter: Value")

  response = ssm.put_parameter(
    Name = name,
    Description = description,
    Value = value,
    Type = "SecureString",
    Overwrite = False
  )

  print("Successfully created encrypted ssm parameter '{}'".format(name))
  c.send(ev, ctx, c.SUCCESS, None, name)

def update(ev, ctx):
  props = ev["ResourceProperties"]
  old_props = ev["OldResourceProperties"]

  name = props["Name"]
  if name is None:
    raise Exception("Missing required parameter: Name")

  description = props["Description"]
  if description is None:
    raise Exception("Missing required parameter: Description")

  value = props["Value"]
  if value is None:
    raise Exception("Missing required parameter: Value")

  response = ssm.put_parameter(
    Name = name,
    Description = description,
    Value = value,
    Type = "SecureString",
    Overwrite = True
  )

  print("Successfully created encrypted ssm parameter '{}'".format(name))
  c.send(ev, ctx, c.SUCCESS, None, name)

def delete(ev, ctx):
  name = ev["PhysicalResourceId"]

  try:
    ssm.delete_parameter(Name = name)
  except Exception as e:
    if e.response["Error"]["Code"] == "ParameterNotFound":
      print("Parameter '{}' not found".format(name))
    else:
      raise

  print("Successfully deleted encrypted ssm parameter '{}'".format(name))
  c.send(ev, ctx, c.SUCCESS, None, name)

def handler(ev, ctx):
  try:
    req_type = ev["RequestType"]
    if req_type == "Delete":
      delete(ev, ctx)
    elif req_type == "Create":
      create(ev, ctx)
    elif req_type == "Update":
      update(ev, ctx)
  except Exception as e:
    print("Error while handling '{}' operation for encrypted ssm parameter '{}'".format(ev["RequestType"], e))
    c.send(ev, ctx, c.FAILED, None, {})
