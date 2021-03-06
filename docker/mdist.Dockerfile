# Pull base image.
FROM julia:1.1.0

MAINTAINER "Robert Feldt" robert.feldt@gmail.com

## Remain current
RUN apt-get update -qq \
&& apt-get dist-upgrade -y \
&& apt-get upgrade

RUN apt-get install -y build-essential

## Add tar and bzip2 and xz just as a convenience if we need them
## when working with large batches of files to be processed.
RUN apt-get install -y tar bzip2 less nano

########################
## Java (for tika)
########################

# Install Java. We only install JRE here, add default-jdk if you need the JDK.
#RUN apt-get update && apt-get install -y default-jre


########################
## poppler-utils for pdftotext
########################

#RUN apt-get install -y poppler-utils


########################
## Copy our files
########################

## Copy the files from this repo to the docker image
COPY . /usr/src/MultiDistances

########################
## Julia packages we need.
########################

# Install julia packages
#COPY docker/installpackages.jl /tmp/installpackages.jl
#RUN  julia /tmp/installpackages.jl

RUN julia -e 'using Pkg; Pkg.add(PackageSpec(url="https://github.com/robertfeldt/MultiDistances.jl", rev="master")); Pkg.add(PackageSpec(url="https://github.com/matthieugomez/StringDistances.jl", rev="master")); Pkg.update(); Pkg.API.precompile();'

# Can't precompile MultiDistances itself, for some reason
RUN cd /usr/src/MultiDistances && julia -e 'using Pkg; Pkg.activate("."); Pkg.API.precompile();'

########################
## Set up our commands
########################

## Link our main commands so that they are in the path and executable.
RUN ln -s /usr/src/MultiDistances/bin/runmdist /usr/bin/mdist \
&&  chmod +x /usr/bin/mdist \
&&  chmod +x /usr/src/MultiDistances/bin/runmdist \
&&  chmod +x /usr/src/MultiDistances/bin/mdistmain


########################
## Working dir path to access files from outside...
########################
WORKDIR /data


########################
## General stuff
########################

CMD ["/bin/bash"]
