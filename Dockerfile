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
# Copy TensorRT into container (accessible by root)
# ------------------------------------------------------------
COPY TensorRT-8.5.1.7 /root/TensorRT-8.5.1.7

# ------------------------------------------------------------
# Mark Git repo as safe
# ------------------------------------------------------------
RUN git config --global --add safe.directory /root/phantom-os-2 || true

# ------------------------------------------------------------
# Set environment variables for TensorRT
# ------------------------------------------------------------
ENV TENSORRT_ROOT=/root/TensorRT-8.5.1.7
ENV PATH=/usr/local/cuda/bin:${TENSORRT_ROOT}/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:${TENSORRT_ROOT}/lib:${LD_LIBRARY_PATH}

# ------------------------------------------------------------
# Append ROS setup and bash completion to root's .bashrc
# ------------------------------------------------------------
RUN echo "if [ -f /etc/bash_completion ]; then . /etc/bash_completion; fi" >> /root/.bashrc

# ------------------------------------------------------------
# Append Phantom OS configuration to root's .bashrc
# ------------------------------------------------------------
RUN echo "" >> /root/.bashrc \
    && echo "############################" >> /root/.bashrc \
    && echo "# Start of Phantom OS config" >> /root/.bashrc \
    && echo "############################" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "# ROS Path Setup" >> /root/.bashrc \
    && echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "# ROS Workspace Path Setup" >> /root/.bashrc \
    && echo "source /usr/local/phantom-os/setup.bash --extend" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "# Phantom OS Env Variable for Param Directory" >> /root/.bashrc \
    && echo "export PHANTOM_PARAM_DIRECTORY=/usr/local/phantom-os/share/phantom_ros/params" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "# Phantom OS Env Variable For Record Directory (Required by Log Server)" >> /root/.bashrc \
    && echo "export PHANTOM_RECORD_DIRECTORY=/media/user/logging/recording" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "# Phantom OS Env Variable Current Phantom Vehicle (Required by Log Server and Sensor Fusion)" >> /root/.bashrc \
    && echo "export PHANTOM_VEHICLE=zf_9100" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "# Phantom OS Env Variable for Country Code" >> /root/.bashrc \
    && echo "export PHANTOM_COUNTRY_CODE=usa" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "# Phantom OS Env Variables for Remote Logging PC (Required on both machines if using remote logging PC. Also requires setup in launch files)" >> /root/.bashrc \
    && echo "export PHANTOM_UDP_LOGGING_ENABLED=false" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "# Set ROS_PACKAGE_PATH based on ROS distribution" >> /root/.bashrc \
    && echo "export ROS_PACKAGE_PATH=/usr/local/phantom-os/share/phantom_ros:/opt/ros/noetic/share" >> /root/.bashrc \
    && echo "" >> /root/.bashrc \
    && echo "############################" >> /root/.bashrc \
    && echo "# End of Phantom OS config" >> /root/.bashrc \
    && echo "############################" >> /root/.bashrc

# ------------------------------------------------------------
# Install additional dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y sshpass net-tools libboost-all-dev libopenblas-dev libopencv-dev \
                       libyaml-cpp-dev qtbase5-dev qtdeclarative5-dev && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Stay as root user
# ------------------------------------------------------------
WORKDIR /root

SHELL ["/bin/bash", "-c"]
CMD ["bash"]
