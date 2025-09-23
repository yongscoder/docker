FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Basic setup
RUN apt-get update && apt-get install -y \
    lsb-release gnupg2 curl build-essential git \
    && rm -rf /var/lib/apt/lists/*

# ROS repo setup
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > \
    /etc/apt/sources.list.d/ros-latest.list' \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add -

# Install ROS Noetic (desktop-full)
RUN apt-get update && apt-get install -y \
    ros-noetic-desktop-full \
    python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init || true && rosdep update

# Source ROS setup on container startup
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
