# SSM parameter Sceptre custom resolver

Install with: `pip install <path to this folder eg ./ssm_parameter>`

https://sceptre.cloudreach.com/2.2.1/docs/resolvers.html

From Sceptre documentation:

>Users can define their own resolvers which are used by Sceptre to resolve the value of a parameter before it is passed to the CloudFormation template.

>A resolver is a Python class which inherits from abstract base class Resolver found in the sceptre.resolvers module.

>Resolvers are require to implement a resolve() function that takes no parameters and to call the base class initializer on initialisation.

>Resolvers may have access to argument, stack_config, environment_config and connection_manager as an attribute of self. For example self.stack_config.

>Sceptre uses the sceptre.resolvers entry point to locate resolver classes. Your custom resolver can be written anywhere and is installed as Python package.

http://jinja.pocoo.org/docs/2.10/templates/#include
"Included templates have access to the variables of the active context by default."
