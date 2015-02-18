# -*- coding: utf-8 -*-

from django.http import Http404

from rest_framework import mixins
from rest_framework import generics

from .models import Country
from .serializers import CountrySerializer


class CountryList(generics.ListAPIView):
    """
    List all countries.
    """
    queryset = Country.objects.all()
    serializer_class = CountrySerializer


class CountryDetail(generics.RetrieveAPIView):
    """
    Detailed information about given country.
    """
    queryset = Country.objects.all()
    serializer_class = CountrySerializer
    lookup_url_kwarg = 'id'
    lookup_field = 'id'
