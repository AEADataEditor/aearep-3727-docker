# syntax=docker/dockerfile:1.2
ARG SRCVERSION=16
ARG SRCTAG=2022-02-18
ARG SRCHUBID=dataeditors
ARG RVERSION=4.2.1
ARG RTYPE=verse

# define the source for Stata
FROM ${SRCHUBID}/stata${SRCVERSION}:${SRCTAG} as stata

# use the source for R

FROM rocker/${RTYPE}:${RVERSION}
COPY --from=stata /usr/local/stata/ /usr/local/stata/
#RUN echo "export PATH=/usr/local/stata:${PATH}" >> /root/.bashrc
ENV PATH "$PATH:/usr/local/stata" 


# The next parts need to be run as root ========================================== ROOT
USER root

# install the gh binaries
RUN \ 
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |  dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
   && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list 

# Install packages needed for aea-scripts
#    and
# Stuff we need from the Stata Docker Image
# https://github.com/AEADataEditor/docker-stata/blob/f2c0d52f133a32c6892fe1f67796322390ce7c35/Dockerfile#L15
# We need to redo this here, since we are using the base image from `rocker`. 
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
         locales \
         libncurses5 \
         libfontconfig1 \
         git \
         nano \
         unzip \
         curl \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Now switch back to the regular user (rstudio) ================================ REGULAR USER
USER rstudio

# install any packages into the home directory as the user,
#COPY setup.do /setup.do
WORKDIR /home/statauser
#RUN /usr/local/stata/stata do /setup.do | tee setup.$(date +%F).log
RUN echo "export PATH=/usr/local/stata:\${PATH}" >> /home/rstudio/.bashrc


RUN echo "export PATH=/home/rstudio/bin:\${PATH}" >> /home/rstudio/.bashrc


# Setup for standard operation
SHELL [ "/bin/bash", "-l", "-c" ]
USER rstudio
#WORKDIR /code

# Setup for Rstudio operation
#USER root
#EXPOSE 8787
#CMD ["/init"]

