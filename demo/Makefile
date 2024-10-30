# Lambdas in Makefile demonstration

SHELL:=/bin/bash

MY_FUNC:=echo test $${lambda}

all:
	@lambda='&& echo test2'; \
            echo 'eval $(MY_FUNC)'; \
            echo $${lambda} ; \
	    eval $(MY_FUNC)
