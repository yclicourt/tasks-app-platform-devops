import pytest
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient
from tasks.models import Task

# --- TESTS DE MODELOS ---


@pytest.mark.django_db
def test_create_task():
    """Prueba que un objeto Task se cree correctamente en la Base de Datos"""
    task = Task.objects.create(
        title="Aprender Flake8",
        description="Configurar el linter en el pipeline",
        done=False,
    )

    assert task.title == "Aprender Flake8"
    assert task.done is False
    # Esto además verifica el método __str__ de tu modelo
    assert str(task) == "Aprender Flake8"


# --- TESTS DE VISTAS / API ---


@pytest.mark.django_db
def test_get_tasks_list_endpoint():
    """Prueba que el endpoint de listar tareas responda con un HTTP 200"""
    # 1. Configurar el cliente de pruebas
    client = APIClient()

    # 2. Crear una tarea de prueba previa en la BD
    Task.objects.create(title="Tarea Inicial", done=False)

    # 3. Hacer la petición a la URL (asumiendo que tu router se llama 'task-list')
    url = reverse("tasks-list")
    response = client.get(url)

    # 4. Verificaciones (Asserts)
    assert response.status_code == status.HTTP_200_OK
    assert len(response.data) == 1
    assert response.data[0]["title"] == "Tarea Inicial"
