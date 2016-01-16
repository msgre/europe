from django.core.management.base import BaseCommand, CommandError
from optparse import make_option

from results.models import Result, AnsweredQuestion

class Command(BaseCommand):
    option_list = BaseCommand.option_list + (
        make_option('--keep',
            type="int",
            default=1,
            help='How many results should be keeped in DB after cleanup'),
        )
    help = 'Clear high scores statistic'

    def handle(self, *args, **options):
        results = list(Result.objects.all())
        count = 0
        for result in results[:-options['keep']]:
            result.delete()
            count += 1
        self.stdout.write("%i results deleted..." % count)
