from django.urls import path
from . import views

urlpatterns = [
    path('' , views.getRoutes , name='Our routes'),
    path('notes/', views.getNotes, name="All Notes"),
    path('notes/<str:id>', views.getNote, name="One Note"),
]