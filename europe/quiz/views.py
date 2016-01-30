# -*- coding: utf-8 -*-

from django.http import Http404

from rest_framework import mixins
from rest_framework import generics

from options.models import Option

from .models import Category
from .serializers import CategorySerializer, QuestionsSerializer


class CategoryList(generics.ListAPIView):
    """
    List all categories.
    """
    queryset = Category.objects.all()
    serializer_class = CategorySerializer


class QuestionList(generics.ListAPIView):
    """
    Get random list of questions for given category.
    """
    serializer_class = QuestionsSerializer
    lookup_url_kwarg = 'id'

    def get_queryset(self):
        (difficulty, pk) = self.kwargs[self.lookup_url_kwarg].split('-')
        try:
            category = Category.objects.get(pk=int(pk))
        except:
            raise Http404
        count = Option.objects.get(key='POCET_OTAZEK')
        return category.get_random_questions(int(count.value))
