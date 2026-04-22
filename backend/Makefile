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
	source ./venv/bin/activate && pytest -v -s tests/unit/

coverage:
	source ./venv/bin/activate && pytest \
		--junitxml=pytest.xml \
		--cov-report=term-missing \
		--cov-report=xml:coverage.xml \
		--cov=src tests/unit/ | tee pytest-coverage.txt

coverage-html:
	source ./venv/bin/activate && pytest -v -s \
		--cov=src \
		--cov-branch \
		--cov-report=html:htmlcov \
		tests/unit/
	@echo "Report disponibile in htmlcov/index.html"
	@open htmlcov/index.html 2>/dev/null || xdg-open htmlcov/index.html 2>/dev/null || true

# Analisi SonarCloud (nessun server locale necessario)
sonar: coverage
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
	test            Esegue i test unitari
	coverage        Run tests + genera coverage.xml e pytest.xml (usati dalla CI)
	coverage-html   Apre il report HTML nel browser
	sonar           Esegue coverage + analisi su SonarCloud
	clean           Pulizia dell'ambiente di sviluppo e degli artefatti
endef

help:
	$(info $(HELP_MESSAGE))