
default:
	@echo "make bootstrap|baseconf|jupyter|jupytersetup"

bootstrap:
	ansible-playbook bootstrap.yml

baseconf:
	ansible-playbook baseconf.yml

texlive:
	ansible-playbook texlive.yml

miniconda:
	ansible-playbook miniconda.yml

jupyter:
	ansible-playbook jupyter.yml

R:
	ansible-playbook rstudio.yml
	ansible-playbook rpackagetest.yml

jupytersetup: texlive miniconda jupyter


