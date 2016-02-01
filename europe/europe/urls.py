from django.conf.urls import patterns, include, url

from django.conf.urls import url
from rest_framework.urlpatterns import format_suffix_patterns
from quiz.views import CategoryList, QuestionList
from geo.views import CountryList, CountryDetail
from results.views import MainResultList, CategoryResultList, ResultRank, CreateScoreRecord
from options.views import OptionList


urlpatterns = [
    url(r'^api/countries$', CountryList.as_view()),
    url(r'^api/countries/(?P<id>\d+)$', CountryDetail.as_view()),

    url(r'^api/categories$', CategoryList.as_view()),

    url(r'^api/questions/(?P<id>(E|H)-\d+)$', QuestionList.as_view()),

    url(r'^api/results$', MainResultList.as_view()),
    url(r'^api/results/(?P<id>(E|H)-\d+)$', CategoryResultList.as_view()),
    url(r'^api/results/(?P<id>(E|H)-\d+)/(?P<time>\d+)$', ResultRank.as_view()),
    url(r'^api/score$', CreateScoreRecord.as_view()),

    url(r'^api/options', OptionList.as_view()),
]

urlpatterns = format_suffix_patterns(urlpatterns)
