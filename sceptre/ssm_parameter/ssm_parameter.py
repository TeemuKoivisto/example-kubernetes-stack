import logging

from sceptre.resolvers import Resolver
from botocore.exceptions import ClientError

class SsmParameterException(Exception):
    pass


"""
Custom resolver that reads parameters from AWS Parameter Store.
Usage:
  !ssm_parameter <parameter_name>~<is_parameter_encrypted_boolean>
  
Example:
  !ssm_parameter /path/to/parameter~true

"""
class SsmParameter(Resolver):

    def __init__(self, *args, **kwargs):
        self.logger = logging.getLogger(__name__)
        super(SsmParameter, self).__init__(*args, **kwargs)

    def resolve(self):
        ssm_parameter = self.argument.split("~")
        if not len(ssm_parameter) == 2:
            raise SsmParameterException("Invalid SSM parameter path: {0}".format(self.argument))

        parameter_name = ssm_parameter[0]
        with_encryption = ssm_parameter[1]
        if not with_encryption in ("true", "false"):
            raise SsmParameterException("Invalid SSM parameter path: {0}, {1} is not valid boolean".format(self.argument, with_encryption))

        self.logger.debug("Resolving SSM parameter by name: {0}, with encryption: {1}".format(parameter_name, with_encryption))

        connection_manager = self.stack.template.connection_manager
        try:
            response = connection_manager.call(
                service="ssm",
                command="get_parameter",
                kwargs={"WithDecryption": with_encryption == "true", "Name": parameter_name}
            )
        except ClientError as e:
            raise e
        else:
            return response["Parameter"]["Value"]
