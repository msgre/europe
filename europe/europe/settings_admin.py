from .settings_base import *

ROOT_URLCONF = 'europe.urls_admin'

INSTALLED_APPS.insert(0, 'django.contrib.admin')
STATIC_URL = '/admin/static/'
