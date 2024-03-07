#!/usr/bin/env bash
set -ex

RDM_ARGS="--password-store=basic --no-sandbox --ignore-gpu-blocklist --user-data-dir --no-first-run --simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT'"
RDM_VERSION=$1

ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')
if [ "$ARCH" == "arm64" ] ; then
  echo "rdm not supported on arm64, skipping rdm installation"
  exit 0
fi	

if [[ "${DISTRO}" == @(centos|oracle8|rockylinux9|rockylinux8|oracle9|almalinux9|almalinux8) ]]; then
  if [ ! -z "${RDM_VERSION}" ]; then
    wget https://cdn.devolutions.net/download/Linux/RDM/2024.1.0.6/RemoteDesktopManager_${RDM_VERSION}_x86_64.rpm -O rdm.rpm
  else
    wget https://cdn.devolutions.net/download/Linux/RDM/2024.1.0.6/RemoteDesktopManager_2024.1.0.6_x86_64.rpm -O rdm.rpm
  fi
  if [[ "${DISTRO}" == @(oracle8|rockylinux9|rockylinux8|oracle9|almalinux9|almalinux8) ]]; then
    dnf localinstall -y rdm.rpm
    if [ -z ${SKIP_CLEAN+x} ]; then
      dnf clean all
    fi
  else
    yum localinstall -y rdm.rpm
    if [ -z ${SKIP_CLEAN+x} ]; then
      yum clean all
    fi
  fi
  rm rdm.rpm
#elif [ "${DISTRO}" == "opensuse" ]; then
#  zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome
#  wget https://dl.google.com/linux/linux_signing_key.pub
#  rpm --import linux_signing_key.pub
#  rm linux_signing_key.pub
#  zypper install -yn google-chrome-stable
#  if [ -z ${SKIP_CLEAN+x} ]; then
#    zypper clean --all
#  fi
else
  apt-get update
  if [ ! -z "${RDM_VERSION}" ]; then
    wget https://cdn.devolutions.net/download/Linux/RDM/2024.1.0.6/RemoteDesktopManager_${RDM_VERSION}_amd64.deb -O rdm.deb
  else
    wget https://cdn.devolutions.net/download/Linux/RDM/2024.1.0.6/RemoteDesktopManager_2024.1.0.6_amd64.deb -O rdm.deb
  fi
  apt-get install -y ./rdm.deb
  rm rdm.deb
  if [ -z ${SKIP_CLEAN+x} ]; then
    apt-get autoclean
    rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/*
  fi
fi

sed -i 's/-stable//g' /usr/share/applications/remotedesktopmanager.desktop

cp /usr/share/applications/remotedesktopmanager.desktop $HOME/Desktop/
chown 1000:1000 $HOME/Desktop/remotedesktopmanager.desktop
chmod +x $HOME/Desktop/remotedesktopmanager.desktop

#mv /usr/bin/remotedesktopmanager /usr/bin/remotedesktopmanager-orig
#cat >/usr/bin/remotedesktopmanager <<EOL
##!/usr/bin/env bash
#if ! pgrep rdm > /dev/null;then
#  rm -f \$HOME/.rdm/Singleton*
#fi
#sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' ~/.config/google-chrome/Default/Preferences
#sed -i 's/"exit_type":"Crashed"/"exit_type":"None"/' ~/.config/google-chrome/Default/Preferences
#if [ -f /opt/VirtualGL/bin/vglrun ] && [ ! -z "\${KASM_EGL_CARD}" ] && [ ! -z "\${KASM_RENDERD}" ] && [ -O "\${KASM_RENDERD}" ] && [ -O "\${KASM_EGL_CARD}" ] ; then
#    echo "Starting rdm with GPU Acceleration on EGL device \${KASM_EGL_CARD}"
#    vglrun -d "\${KASM_EGL_CARD}" /opt/google/chrome/google-chrome ${RDM_ARGS} "\$@" 
#else
    echo "Starting rdm"
    /bin/remotedesktopmanager ${RDM_ARGS}
#fi
#EOL
chmod +x /usr/bin/remotedesktopmanager
#cp /usr/bin/google-chrome /usr/bin/chrome


# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
