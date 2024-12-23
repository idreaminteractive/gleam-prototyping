FROM gitpod/workspace-full:2024-12-04-13-05-19
RUN sudo apt-get update && sudo apt-get install -y docker-buildx-plugin sqlite wget inotify-tools

RUN brew install asdf

RUN export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
RUN asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
RUN asdf plugin-add rebar https://github.com/Stratus3D/asdf-rebar.git
RUN asdf plugin-add gleam

# install our versions
ENV GLEAM_VERSION=1.6.3
ENV ERLANG_VERSION=27.1.2
ENV REBAR_VERSION=3.24.0
RUN echo "gleam ${GLEAM_VERSION}\nerlang ${ERLANG_VERSION}\nrebar ${REBAR_VERSION}" | tee -a .tool-versions
RUN asdf install 
RUN echo 'export PATH=$PATH:/$HOME/.asdf/shims' >> .bashrc

# fly
RUN curl -L https://fly.io/install.sh | sh
ENV FLYCTL_INSTALL="/home/gitpod/.fly"
ENV PATH="$FLYCTL_INSTALL/bin:$PATH"


# dbmate
RUN sudo curl -fsSL -o /usr/local/bin/dbmate https://github.com/amacneil/dbmate/releases/latest/download/dbmate-linux-amd64
RUN sudo chmod +x /usr/local/bin/dbmate


# watch exec
RUN brew install watchexec


# install doppler locally.
RUN (curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh || wget -t 3 -qO- https://cli.doppler.com/install.sh) | sudo sh

# RUN go install github.com/mailhog/MailHog@latest


# alias all the things
RUN echo 'alias home="cd ${GITPOD_REPO_ROOT}"' | tee -a ~/.bashrc ~/.zshrc

