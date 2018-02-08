FROM base/archlinux:latest
MAINTAINER sykuang <sykuang.tw@gmail.com>

# Add Taiwan and US server to mirrolist
RUN curl https://www.archlinux.org/mirrorlist/?country=TW&country=US&protocol=http >> /etc/pacman.d/mirrorlist && \
    pacman -Syu

RUN pacman -S --noconfirm sudo git vim base-devel
# Install yaourt
RUN echo "[archlinuxfr]" >> /etc/pacman.conf && \
    echo "SigLevel = Never" >> /etc/pacman.conf && \
    echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf && \
    pacman -Syu --noconfirm yaourt && \
    useradd --create-home docker && \
    echo -e "docker\ndocker" | passwd docker && \
    echo "docker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    # Install HPN and X11
    runuser -l docker -c "yaourt --noconfirm -S openssh-hpn-git" && \
    pacman --noconfirm -S xterm xorg-xclock xorg-xcalc xorg-xauth xorg-xeyes ttf-droid
# Generate locale en_US
RUN sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/'  /etc/locale.gen && \
    locale-gen
# Set SSH Server
RUN sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    echo "X11Forwarding yes" >> /etc/ssh/sshd_config && \
    echo "X11UseLocalhost no" >> /etc/ssh/sshd_config && \
    runuser -l docker -c "touch /home/docker/.Xauthority" && \
    touch $HOME/.Xauthority

RUN ssh-keygen -A

# Cleanup
RUN rm -r /tmp/* && \
    rm -r /usr/share/man/* && \
    rm -r /usr/share/doc/* && \
    bash -c "echo 'y' | pacman -Scc >/dev/null 2>&1" && \
    paccache -rk0 >/dev/null 2>&1 &&  \
    pacman-optimize && \
    rm -r /var/lib/pacman/sync/*

EXPOSE 22
ENV LANG=en_US.UTF-8
CMD ["/bin/sshd","-D"]