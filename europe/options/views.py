# -*- coding: utf-8 -*-

from rest_framework import generics

from .models import Option
from .serializers import OptionSerializer


class OptionList(generics.ListAPIView):
    """
    List all options saved in Django application.
    """
    serializer_class = OptionSerializer
    paginate_by = 1000

    def get_queryset(self):
        return Option.objects.all()
