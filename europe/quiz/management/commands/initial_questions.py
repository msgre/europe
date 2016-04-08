# -*- coding: utf-8 -*-

import imp
import os

from django.core.management.base import BaseCommand, CommandError
from django.conf import settings

class Command(BaseCommand):
    args = '<path>'
    help = 'Load initial questions data into database'

    def handle(self, *args, **options):
        if len(args) < 1:
            raise CommandError('Provide path to directory with initial content please.')
        path = args[0]

        if not os.path.exists(path):
            raise CommandError('Path "{}" doesn\'t exist.'.format(path))

        # http://stackoverflow.com/a/973488
        subdirs = next(os.walk(path))[1]

        modules = {}
        for subdir in subdirs:
            filepath = os.path.join(path, subdir, 'initial.py')
            if not os.path.exists(filepath):
                continue
            self.stdout.write('Loading initial data from "{}" file.'.format(filepath))
            modules[subdir] = imp.load_source(subdir, filepath)
            modules[subdir].load(self.stdout, self.stderr)
        self.stdout.write('Done!')
