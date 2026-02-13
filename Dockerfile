ARG IMAGE
FROM $IMAGE

USER root

# Install any extra packages
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    build-essential \
    rclone \
    nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}

# Replace all favicons with Nectar logo and install our theme extension
COPY favicon.ico /tmp
RUN cp /tmp/favicon.ico /opt/conda/share/jupyterhub/static/favicon.ico || true && \
    cp /tmp/favicon.ico /opt/conda/lib/python3.13/site-packages/jupyter_server/static/favicon.ico || true && \
    cp /tmp/favicon.ico /opt/conda/lib/python3.13/site-packages/jupyter_server/static/favicons/favicon.ico || true && \
    cp /tmp/favicon.ico /opt/conda/lib/python3.13/site-packages/nbclassic/static/base/images/favicon.ico || true && \
    cp /tmp/favicon.ico /opt/conda/lib/python3.13/site-packages/nbclassic/static/favicon.ico || true && \
    cp /tmp/favicon.ico /opt/conda/lib/python3.13/site-packages/notebook/static/base/images/favicon.ico || true && \
    cp /tmp/favicon.ico /opt/conda/lib/python3.13/site-packages/notebook/static/favicon.ico || true && \
    pip install git+https://github.com/andybotting/nectar_jupyterlab_theme.git && \
    pip install jupyter-resource-usage

# Install Python 3 packages
RUN mamba install --yes \
    's3contents' \
    'hybridcontents' \
    'nodejs' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

RUN mamba install --quiet --yes s3contents hybridcontents && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

ENV PATH="${HOME}/.local/bin:${PATH}" \
    PIP_USER=1
