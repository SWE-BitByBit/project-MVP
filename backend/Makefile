SHELL := /bin/bash
PIP ?= pip3
PYTHON ?= python3
SONAR_TOKEN ?= 8dbef9dd3740b3fa17be1de5706958dbc736bf63

clean:
	rm -rf ./venv/ \
	.coverage \
	coverage.xml \
	htmlcov/ \
    pytest-coverage.txt \
	pytest.xml \
	.aws-sam/ 

checkOSDependencies:
	$(PYTHON) --version

install: checkOSDependencies
	$(PYTHON) -m venv venv
	source ./venv/bin/activate && $(PIP) install -r tests/requirements.txt

deps:
	source ./venv/bin/activate && $(PIP) install -r tests/requirements.txt

test:
	source ./venv/bin/activate && pytest -v -s tests/unit/ tests/integration/

test-unit:
	source ./venv/bin/activate && pytest -v -s tests/unit/

test-integration:
	export AWS_DEFAULT_REGION=eu-south-1 && \
	source ./venv/bin/activate && pytest -v -s tests/integration/

coverage:
	export AWS_DEFAULT_REGION=eu-south-1 && \
	export TABLE_CHATS=chats_mvp && \
	export TABLE_MESSAGES=chats_messages_mvp && \
	source ./venv/bin/activate && \
	coverage erase && \
	coverage run --append --source=src --branch -m pytest --junitxml=pytest.xml tests/unit/chatbot/ && \
	coverage run --append --source=src --branch -m pytest --junitxml=pytest.xml tests/integration/chatbot/ && \
	coverage run --append --source=src --branch -m pytest --junitxml=pytest.xml tests/integration/materials/ && \
	coverage run --append --source=src --branch -m pytest --junitxml=pytest.xml tests/integration/trusted_contact/ && \
	coverage run --append --source=src --branch -m pytest --junitxml=pytest.xml tests/integration/safe_places/ && \
	coverage run --append --source=src --branch -m pytest --junitxml=pytest.xml tests/integration/diary/ && \
	coverage run --append --source=src --branch -m pytest --junitxml=pytest.xml tests/unit/diary/ && \
	coverage run --append --source=src --branch -m pytest --junitxml=pytest.xml tests/unit/materials/ && \
	coverage run --append --source=src --branch -m pytest --junitxml=pytest.xml tests/unit/safe_places/ && \
	coverage run --append --source=src --branch -m pytest --junitxml=pytest.xml tests/unit/trusted_contact/ && \
	coverage xml -o coverage.xml && \
	coverage report --show-missing | tee pytest-coverage.txt

coverage-html:
	export AWS_DEFAULT_REGION=eu-south-1 && \
	export TABLE_CHATS=chats_mvp && \
	export TABLE_MESSAGES=chats_messages_mvp && \
	source ./venv/bin/activate && \
	coverage erase && \
	coverage run --append --source=src --branch -m pytest tests/unit/chatbot/ && \
	coverage run --append --source=src --branch -m pytest tests/integration/chatbot/ && \
	coverage run --append --source=src --branch -m pytest tests/integration/materials/ && \
	coverage run --append --source=src --branch -m pytest tests/integration/trusted_contact/ && \
	coverage run --append --source=src --branch -m pytest tests/integration/safe_places/ && \
	coverage run --append --source=src --branch -m pytest tests/integration/diary/ && \
	coverage run --append --source=src --branch -m pytest tests/unit/diary/ && \
	coverage run --append --source=src --branch -m pytest tests/unit/materials/ && \
	coverage run --append --source=src --branch -m pytest tests/unit/safe_places/ && \
	coverage run --append --source=src --branch -m pytest tests/unit/trusted_contact/ && \
	coverage html -d htmlcov && \
	coverage report --show-missing
	@echo "Report disponibile in htmlcov/index.html"
	@open htmlcov/index.html 2>/dev/null || xdg-open htmlcov/index.html 2>/dev/null || true

# Analisi SonarCloud (nessun server locale necessario)
sonar: coverage
	export AWS_DEFAULT_REGION=eu-south-1 && \
	export TABLE_CHATS=chats_mvp && \
	export TABLE_MESSAGES=chats_messages_mvp && \
	source ./venv/bin/activate && pysonar \
		--sonar-host-url=https://sonarcloud.io \
		--sonar-token=$(SONAR_TOKEN) \
		--sonar-project-key=swe-bitbybit_project_MVP-backend

build:
	source ./venv/bin/activate && sam build

deploy: build
	source ./venv/bin/activate
	sam deploy

#############
#  Helpers  #
#############
define HELP_MESSAGE
	Usage: make <command>

	Commands:
	build           Build Lambda function and dependencies
	deploy          Deploy subsequent changes
	install         Install application and dev dependencies defined in requirements.txt
	deps            Install project dependencies locally
	test             Esegue tutti i test (unit + integration)
	test-unit        Esegue solo i test di unità
	test-integration Esegue solo i test di integrazione
	coverage        Run tests + genera coverage.xml e pytest.xml (usati dalla CI)
	coverage-html   Apre il report HTML nel browser
	sonar           Esegue coverage + analisi su SonarCloud
	clean           Pulizia dell'ambiente di sviluppo e degli artefatti
endef

help:
	$(info $(HELP_MESSAGE))