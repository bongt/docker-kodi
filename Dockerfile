# ehough/docker-kodi - Dockerized Kodi with audio and video.
#
# https://github.com/ehough/docker-kodi
# https://hub.docker.com/r/erichough/kodi/
#
# Copyright 2018-2021 - Eric Hough (eric@tubepress.com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

FROM ubuntu:jammy

ARG KODI_VERSION=19.4

# https://github.com/ehough/docker-nfs-server/pull/3#issuecomment-387880692
ARG DEBIAN_FRONTEND=noninteractive

# apt-get -y purge openssl (if not needed for barrier to work)
# install the team-xbmc ppa
RUN apt-get update									&& \
    apt-get install -y --no-install-recommends gpg-agent software-properties-common	&& \
    add-apt-repository -y ppa:team-xbmc/ppa						&& \
    add-apt-repository -y universe							&& \
    apt-get update									&& \
    apt-get -y install barrier alsa-utils			 					&& \
    apt-get -y purge ca-certificates gpg-agent software-properties-common		&& \
    apt-get -y --purge autoremove							&& \
    rm -rf /var/lib/apt/lists/*
                                                 
ARG KODI_EXTRA_PACKAGES=                         
                                                 
# besides kodi, we will install a few extra packages:
#  - ca-certificates              allows Kodi to properly establish HTTPS connections
#  - kodi-eventclients-kodi-send  allows us to shut down Kodi gracefully upon container termination
#  - kodi-inputstream-*           input stream add-ons
#  - locales                      additional spoken language support (via x11docker --lang option)
#  - pulseaudio                   in case the user prefers PulseAudio instead of ALSA
#  - tzdata                       necessary for timezone selection
#  - va-driver-all                the full suite of drivers for the Video Acceleration API (VA API)
#  - intel-media-va-driver        iHD driver for the Video Acceleration API (VA API)
#  - vdpau-driver-all             VDPAU driver suite

RUN packages="                                               \
                                                             \
    ca-certificates                                          \
    kodi=2:${KODI_VERSION}+*                                 \
    kodi-eventclients-kodi-send                              \
    kodi-inputstream-adaptive                                \
    kodi-inputstream-rtmp                                    \
    locales                                                  \
    tzdata                                                   \
    #pulseaudio                                               \
    va-driver-all                                            \
    intel-media-va-driver                                    \
    #vdpau-driver-all                                        \
    ${KODI_EXTRA_PACKAGES}"                               && \
                                                             \
    apt-get update                                        && \
    apt-get install -y --no-install-recommends $packages  && \
    apt-get -y --purge autoremove                         && \
    rm -rf /var/lib/apt/lists/*


# couldn't get HDMI audio (ALSA) to work with env vars -> /etc/asound.conf
# COPY asound.conf /etc/asound.conf

# setup entry point
COPY entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
