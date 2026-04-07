test:
    flutter test test/

coverage:
    flutter test --coverage test/

analyze:
    flutter analyze

clean:
    flutter clean
    rm -rf coverage/

#############
#  Helpers  #
#############
define HELP_MESSAGE
	Usage: make <command>

	Commands:
	test            Esegue i test unitari
	coverage        genera file lcov.info
	analyze         Analizza il codice sorgente
	clean           Pulizia dell'ambiente di sviluppo e degli artefatti 
endef

help:
	$(info $(HELP_MESSAGE))