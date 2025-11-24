# ------------------------------------------------------------
# Base image
# ------------------------------------------------------------
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------
# Common dependencies + CarMaker GUI/OpenGL libs
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    build-essential cmake git wget curl unzip \
    lsb-release gnupg2 sudo vim software-properties-common \
    python3 python3-pip \
    libx11-dev libglu1-mesa-dev libxi-dev libxmu-dev freeglut3-dev \
    libcanberra-gtk-module libcanberra-gtk3-module \
    bash bash-completion \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Install ROS Noetic (as root)
# ------------------------------------------------------------
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add - && \
    apt-get update && apt-get install -y \
        ros-noetic-desktop-full \
        python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true && rosdep update

# ------------------------------------------------------------
# Create default user 'root' with build-time UID/GID
# ------------------------------------------------------------
ARG USERNAME=root
ARG USER_UID=1000
ARG USER_GID=1000

# Only create user/group if not root (root already exists)
RUN if [ "$USERNAME" != "root" ]; then \
        groupadd --gid $USER_GID $USERNAME || true \
        && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME || true \
        && usermod -aG sudo $USERNAME || true; \
    fi

# ------------------------------------------------------------
# Copy TensorRT into container
# ------------------------------------------------------------
COPY TensorRT-8.5.1.7 /home/root/TensorRT-8.5.1.7

# ------------------------------------------------------------
# Mark Git repo as safe
# ------------------------------------------------------------
RUN git config --global --add safe.directory /home/$USERNAME/phantom-os-2 || true

# ------------------------------------------------------------
# Set environment variables for TensorRT
# ------------------------------------------------------------
ENV TENSORRT_ROOT=/home/$USERNAME/TensorRT-8.5.1.7
ENV PATH=/usr/local/cuda/bin:${TENSORRT_ROOT}/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:${TENSORRT_ROOT}/lib:${LD_LIBRARY_PATH}

# ------------------------------------------------------------
# Append ROS setup and bash completion to user's .bashrc
# ------------------------------------------------------------
RUN echo "source /opt/ros/noetic/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "if [ -f /etc/bash_completion ]; then . /etc/bash_completion; fi" >> /home/$USERNAME/.bashrc \
    && chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc

# ------------------------------------------------------------
# Switch to root user
# ------------------------------------------------------------
USER $USERNAME
WORKDIR /home/$USERNAME

SHELL ["/bin/bash", "-c"]
CMD ["bash"]
