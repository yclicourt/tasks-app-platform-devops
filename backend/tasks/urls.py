from django.urls import path, include
from rest_framework import routers
from .views import TaskView

router = routers.DefaultRouter()

router.register(r"", TaskView, basename="tasks")

urlpatterns = [
    path("", include(router.urls)),
]
