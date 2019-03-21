# Format these environment-specific settings as a dictionary, in order to:
# - mimic the use of environment variables in other settings files
#   os.environ.get() vs env.environ.get()
# - enable the use of defaults
#   env.environ.get('LEVEL_OF_AWESOME', 0)
# - enable the use of Python types (int, bool, etc)
# - provide those with little knowledge of the vagrant provisioning process, or
#   environment variables in general, a single point of reference for all
#   environment-specific settings and a visible source for those magically
#   obtained settings values.
#
# While this is Python, the convention should be to use simple name/value pairs
# in the dictionary below, without the use of code statements (conditionals,
# loops, etc). Such statements should be left to the other settings files,
# though they could be based on some setting/s below.
# The idea is to provide an easy reference to, and use of, environment-specific
# settings, without violating 12factor (http://12factor.net/) too heavily (by
# having code that is not committed to source control)

environ = {
    'DEBUG': {{debug}},
    'SECRET_KEY': r'{{secret_key}}',
    'TIME_ZONE': '{{time_zone}}',
    'DB_USER': '{{project_name}}',
    'DB_PASSWORD': r'{{db_password}}'
}
