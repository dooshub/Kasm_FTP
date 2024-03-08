FROM kasmweb/core-ubuntu-focal:1.15.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

COPY ./software/ $INST_SCRIPTS/rdm/

RUN apt-get update \
    && apt-get install -y apt-transport-https libwebkit2gtk-4.0 ca-certificates libsecret-1-0 gnome-keyring libvte-2.91 \
    && sudo dpkg -i $INST_SCRIPTS/rdm/RemoteDesktopManager_2024.1.0.6_amd64.deb \
    && rm /dockerstartup/install/rdm/RemoteDesktopManager_2024.1.0.6_amd64.deb \
    && cp /usr/share/applications/remotedesktopmanager.desktop $HOME/Desktop/ \
    && chmod +x $HOME/Desktop/remotedesktopmanager.desktop \
    && chown 1000:1000 $HOME/Desktop/remotedesktopmanager.desktop

RUN echo "/usr/bin/desktop_ready && /usr/lib/devolutions/RemoteDesktopManager/RemoteDesktopManager &" > $STARTUPDIR/custom_startup.sh \
    && chmod +x $STARTUPDIR/custom_startup.sh

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
