import os

try:
    SECRET_KEY = open(os.path.join(os.path.dirname(__file__), '.secret_key')).read().strip()
except:
    SECRET_KEY = 'ubl76$fv7lji_fqvl-2hw0=k#09aj%71n&ancqki3p((-f*u4_'
