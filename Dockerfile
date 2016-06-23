# Inherit from Heroku's stack
FROM heroku/cedar:14
MAINTAINER Darwin Monroy <contact@darwinmonroy.com>

# Internally, we arbitrarily use port 3000
ENV PORT 3000

# Add Python binaries to path.
ENV PATH /app/.heroku/python/bin/:$PATH

# Create some needed directories
RUN mkdir -p /app/.heroku/python /app/.profile.d
WORKDIR /app/user

# Load project's runtime
ONBUILD ADD runtime.txt /app/user/runtime.txt

# Install Python and setup environment
ONBUILD RUN PYTHON_VERSION=`cat runtime.txt` \
  && export PYTHON_VERSION \
  && curl -s https://lang-python.s3.amazonaws.com/cedar-14/runtimes/$PYTHON_VERSION.tar.gz | tar zx -C /app/.heroku/python \
  && curl -s https://bootstrap.pypa.io/get-pip.py | /app/.heroku/python/bin/python \
  && echo 'export PATH=$HOME/.heroku/python/bin:$PATH PYTHONUNBUFFERED=true PYTHONHOME=/app/.heroku/python LIBRARY_PATH=/app/.heroku/vendor/lib:/app/.heroku/python/lib:$LIBRARY_PATH LD_LIBRARY_PATH=/app/.heroku/vendor/lib:/app/.heroku/python/lib:$LD_LIBRARY_PATH LANG=${LANG:-en_US.UTF-8} PYTHONHASHSEED=${PYTHONHASHSEED:-random} PYTHONPATH=${PYTHONPATH:-/app/user/}' > /app/.profile.d/python.sh \
  && chmod +x /app/.profile.d/python.sh

# Load hooks
ONBUILD ADD bin/pre_compile /app/user/bin/pre_compile
# pre_compile hook
ONBUILD RUN if [ -f /app/user/bin/pre_compile ]; then /app/user/bin/pre_compile ; fi

ONBUILD ADD requirements.txt /app/user/
ONBUILD RUN /app/.heroku/python/bin/pip install -r requirements.txt

ONBUILD ADD . /app/user/
