from setuptools import setup

setup(
    name='ssm_parameter',
    version='0.0.1',
    py_modules=['ssm_parameter'],
    entry_points={
        'sceptre.resolvers': [
            'ssm_parameter = ssm_parameter:SsmParameter',
        ],
    }
)
