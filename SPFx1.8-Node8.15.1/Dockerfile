FROM node:8.15.1

EXPOSE 5432 4321 35729

RUN npm i -g gulp yo @microsoft/generator-sharepoint @pnp/office365-cli

VOLUME /usr/app/spfx
WORKDIR /usr/app/spfx
RUN useradd --create-home --shell /bin/bash spfx && \
    usermod -aG sudo spfx && \
    chown -R spfx:spfx /usr/app/spfx

USER spfx

CMD /bin/bash
