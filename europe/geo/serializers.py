# -*- coding: utf-8 -*-

from .models import Country
from rest_framework import serializers


class CountrySerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Country
        fields = ('id', 'title', 'sensor', )
        lookup_field = 'id'
