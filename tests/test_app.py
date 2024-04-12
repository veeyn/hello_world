import pytest
from hello_world.app import app as flask_app


@pytest.fixture
def app():
    yield flask_app

@pytest.fixture
def client(app):
    return app.test_client()

def test_home_status_code(client):
    response = client.get("/")
    assert response.status_code == 200

def test_hello_content(client):
    response = client.get("/hello")
    assert response.json == {'message': 'Hello world'}
    assert response.status_code == 200
